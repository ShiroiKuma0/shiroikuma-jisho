package shiroikuma.jisho;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.FloatBuffer;
import java.nio.LongBuffer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import ai.onnxruntime.OnnxTensor;
import ai.onnxruntime.OrtEnvironment;
import ai.onnxruntime.OrtSession;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * On-device Japanese OCR backed by PP-OCRv6 (small tier) running under
 * ONNX Runtime. Replaces Google ML Kit, which was the app's only
 * tracker: it registered {@code MlKitInitProvider} and
 * {@code MlKitComponentDiscoveryService} in the merged manifest, both of
 * which start on their own at process launch.
 *
 * Channel: {@code shiroikuma.jisho/ocr}
 * Methods:
 *   recognizeFile(path, maxSide?)                -> result map
 *   recognizeBitmap(rgba, width, height, maxSide?) -> result map
 *   dispose()                                    -> null
 *
 * Result map:
 *   {text: String,
 *    blocks: [{text, l, t, r, b, vertical,
 *              lines: [{text, l, t, r, b}]}]}
 *
 * The pipeline mirrors PaddleOCR's own inference path, with the
 * parameters taken from the models' published {@code inference.yml}:
 * DB detection at threshold 0.2 / box threshold 0.45 / unclip 1.4, then
 * CTC recognition at height 48. Two things are specific to Japanese and
 * are the reason this is not a thin wrapper:
 *
 *  - Tategaki. A detected column is taller than it is wide; rotating the
 *    crop so its top edge becomes the left edge turns it into the
 *    horizontal line the recogniser expects, and reading order within a
 *    block then runs right to left.
 *  - Orientation is decided per group, never per box. A lone trailing
 *    「。」 is nearly square, so on its own it would be judged
 *    horizontal and misread; it inherits the orientation of the column
 *    it was merged into.
 *
 * All work runs on a single background thread, which doubles as the lock
 * on the two ORT sessions. Results are posted back on the main looper as
 * the platform channel requires.
 */
public class OcrBridge {
    private static final String OCR_CHANNEL = "shiroikuma.jisho/ocr";

    /** DB post-processing, from the detection model's inference.yml. */
    private static final float DET_THRESH = 0.2f;
    private static final float DET_BOX_THRESH = 0.45f;
    private static final float DET_UNCLIP_RATIO = 1.4f;

    /**
     * Long-side cap for the detector's input. 960 is PaddleOCR's own
     * default and measured best here: a 1400x2000 tategaki page scored
     * 1.3% CER at 960 and no better at 1280 or 1600, for half the time.
     */
    private static final int DET_DEFAULT_MAX_SIDE = 960;

    /** The detector's stride: both input sides must be a multiple. */
    private static final int DET_STRIDE = 32;

    private static final int REC_HEIGHT = 48;
    /**
     * Recognition width follows the batch's widest aspect ratio rather
     * than sitting at a fixed 320. A 44-glyph tategaki column is ~44:1;
     * pinned at 320 it gets crushed to 7 px per character, which measured
     * 63% CER against 1.3% once the width was allowed to grow.
     */
    private static final int REC_MIN_WIDTH = 320;
    private static final int REC_MAX_WIDTH = 3200;
    private static final int REC_BATCH = 6;

    /**
     * PaddleOCR's own default drop_score. A detected region that
     * recognises with low mean confidence is nearly always noise --
     * page grain, a panel border, part of a drawing -- and passing it
     * on would put junk into a subtitle or an overlay.
     */
    private static final float REC_DROP_SCORE = 0.5f;

    /**
     * ImageNet statistics, applied positionally to a BGR image because
     * the detector's inference.yml declares {@code img_mode: BGR} and
     * was trained that way.
     */
    private static final float[] DET_MEAN = {0.485f, 0.456f, 0.406f};
    private static final float[] DET_STD = {0.229f, 0.224f, 0.225f};

    private static final String ASSET_DIR = "ocr";
    private static final String DET_MODEL = "ppocrv6_det.onnx";
    private static final String REC_MODEL = "ppocrv6_rec.onnx";
    private static final String KEYS_FILE = "ppocrv6_keys.txt";

    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private Context appContext;
    private OrtEnvironment environment;
    private OrtSession detSession;
    private OrtSession recSession;
    /** CTC label table: index 0 is the blank, the last entry is a space. */
    private String[] charTable;

    void register(@NonNull FlutterEngine flutterEngine, @NonNull Context context) {
        appContext = context.getApplicationContext();
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), OCR_CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "recognizeFile": {
                            final String path = call.argument("path");
                            final Integer maxSide = call.argument("maxSide");
                            executor.execute(() -> recognizeFile(path, maxSide, result));
                            break;
                        }
                        case "recognizeBitmap": {
                            final byte[] rgba = call.argument("rgba");
                            final Integer width = call.argument("width");
                            final Integer height = call.argument("height");
                            final Integer maxSide = call.argument("maxSide");
                            executor.execute(() -> recognizeRgba(
                                rgba,
                                width == null ? 0 : width,
                                height == null ? 0 : height,
                                maxSide, result));
                            break;
                        }
                        case "dispose": {
                            executor.execute(() -> {
                                closeQuietly();
                                succeed(result, null);
                            });
                            break;
                        }
                        default:
                            result.notImplemented();
                    }
                });
    }

    // ---------------------------------------------------------------
    // Entry points
    // ---------------------------------------------------------------

    private void recognizeFile(String path, Integer maxSide, MethodChannel.Result result) {
        Bitmap bitmap = null;
        try {
            bitmap = BitmapFactory.decodeFile(path);
            if (bitmap == null) {
                throw new IOException("could not decode image: " + path);
            }
            succeed(result, run(bitmap, sideOf(maxSide)));
        } catch (Throwable e) {
            fail(result, "recognizeFile", e);
        } finally {
            if (bitmap != null) {
                bitmap.recycle();
            }
        }
    }

    private void recognizeRgba(byte[] rgba, int width, int height,
                               Integer maxSide, MethodChannel.Result result) {
        Bitmap bitmap = null;
        try {
            if (rgba == null || width <= 0 || height <= 0
                    || rgba.length < width * height * 4) {
                throw new IllegalArgumentException("malformed RGBA bitmap");
            }
            int[] pixels = new int[width * height];
            for (int i = 0; i < pixels.length; i++) {
                int o = i * 4;
                int a = rgba[o + 3] & 0xFF;
                // Subtitle bitmaps are text on a transparent field.
                // Compositing over black keeps the detector's input
                // clean instead of letting stray colour through where
                // alpha is zero.
                int r = ((rgba[o] & 0xFF) * a) / 255;
                int g = ((rgba[o + 1] & 0xFF) * a) / 255;
                int b = ((rgba[o + 2] & 0xFF) * a) / 255;
                pixels[i] = 0xFF000000 | (r << 16) | (g << 8) | b;
            }
            bitmap = Bitmap.createBitmap(pixels, width, height, Bitmap.Config.ARGB_8888);
            succeed(result, run(bitmap, sideOf(maxSide)));
        } catch (Throwable e) {
            fail(result, "recognizeBitmap", e);
        } finally {
            if (bitmap != null) {
                bitmap.recycle();
            }
        }
    }

    private static int sideOf(Integer maxSide) {
        return (maxSide == null || maxSide <= 0) ? DET_DEFAULT_MAX_SIDE : maxSide;
    }

    // ---------------------------------------------------------------
    // Pipeline
    // ---------------------------------------------------------------

    private Map<String, Object> run(Bitmap bitmap, int maxSide) throws Exception {
        ensureLoaded();

        int width = bitmap.getWidth();
        int height = bitmap.getHeight();

        List<int[]> boxes = mergeFragments(detect(bitmap, maxSide));
        if (boxes.isEmpty()) {
            return emptyResult();
        }

        // Provisional orientation from each box's own aspect, then a
        // per-group vote so ambiguous fragments inherit their column's.
        boolean[] vertical = new boolean[boxes.size()];
        for (int i = 0; i < boxes.size(); i++) {
            vertical[i] = shapeOf(boxes.get(i)) == SHAPE_VERTICAL;
        }
        List<List<Integer>> groups = groupBlocks(boxes, vertical);
        for (List<Integer> group : groups) {
            int votesVertical = 0;
            int votesHorizontal = 0;
            for (int i : group) {
                int shape = shapeOf(boxes.get(i));
                if (shape == SHAPE_VERTICAL) {
                    votesVertical++;
                } else if (shape == SHAPE_HORIZONTAL) {
                    votesHorizontal++;
                }
            }
            boolean isVertical = votesVertical > 0 || votesHorizontal > 0
                ? votesVertical >= votesHorizontal
                : false;
            for (int i : group) {
                vertical[i] = isVertical;
            }
        }

        String[] texts = recognize(bitmap, boxes, vertical);

        List<Map<String, Object>> blockMaps = new ArrayList<>();
        StringBuilder all = new StringBuilder();
        for (List<Integer> group : orderBlocks(groups, boxes, vertical)) {
            List<Integer> ordered = orderWithinBlock(group, boxes, vertical);
            List<Map<String, Object>> lineMaps = new ArrayList<>();
            StringBuilder blockText = new StringBuilder();
            int l = Integer.MAX_VALUE;
            int t = Integer.MAX_VALUE;
            int r = Integer.MIN_VALUE;
            int b = Integer.MIN_VALUE;
            for (int i : ordered) {
                String text = texts[i];
                if (text == null || text.isEmpty()) {
                    continue;
                }
                int[] box = boxes.get(i);
                l = Math.min(l, box[0]);
                t = Math.min(t, box[1]);
                r = Math.max(r, box[2]);
                b = Math.max(b, box[3]);
                if (blockText.length() > 0) {
                    blockText.append('\n');
                }
                blockText.append(text);
                lineMaps.add(rect(box, text));
            }
            if (lineMaps.isEmpty()) {
                continue;
            }
            Map<String, Object> block = new HashMap<>();
            block.put("text", blockText.toString());
            block.put("l", l);
            block.put("t", t);
            block.put("r", r);
            block.put("b", b);
            block.put("vertical", vertical[ordered.get(0)]);
            block.put("lines", lineMaps);
            blockMaps.add(block);
            if (all.length() > 0) {
                all.append('\n');
            }
            all.append(blockText);
        }

        Map<String, Object> out = new HashMap<>();
        out.put("text", all.toString());
        out.put("blocks", blockMaps);
        return out;
    }

    private static Map<String, Object> rect(int[] box, String text) {
        Map<String, Object> map = new HashMap<>();
        map.put("text", text);
        map.put("l", box[0]);
        map.put("t", box[1]);
        map.put("r", box[2]);
        map.put("b", box[3]);
        return map;
    }

    private static Map<String, Object> emptyResult() {
        Map<String, Object> out = new HashMap<>();
        out.put("text", "");
        out.put("blocks", new ArrayList<Map<String, Object>>());
        return out;
    }

    // ---------------------------------------------------------------
    // Detection
    // ---------------------------------------------------------------

    private List<int[]> detect(Bitmap bitmap, int maxSide) throws Exception {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        double scale = Math.min((double) maxSide / Math.max(width, height), 1.0);
        int netWidth = roundToStride(width * scale);
        int netHeight = roundToStride(height * scale);

        Bitmap scaled = Bitmap.createScaledBitmap(bitmap, netWidth, netHeight, true);
        int[] pixels = new int[netWidth * netHeight];
        scaled.getPixels(pixels, 0, netWidth, 0, 0, netWidth, netHeight);
        if (scaled != bitmap) {
            scaled.recycle();
        }

        int plane = netWidth * netHeight;
        float[] input = new float[3 * plane];
        for (int i = 0; i < plane; i++) {
            int c = pixels[i];
            float b = (c & 0xFF) / 255f;
            float g = ((c >> 8) & 0xFF) / 255f;
            float r = ((c >> 16) & 0xFF) / 255f;
            input[i] = (b - DET_MEAN[0]) / DET_STD[0];
            input[plane + i] = (g - DET_MEAN[1]) / DET_STD[1];
            input[2 * plane + i] = (r - DET_MEAN[2]) / DET_STD[2];
        }

        float[] probability = new float[plane];
        try (OnnxTensor tensor = OnnxTensor.createTensor(
                environment, FloatBuffer.wrap(input),
                new long[]{1, 3, netHeight, netWidth});
             OrtSession.Result result = detSession.run(
                 Collections.singletonMap(detInputName(), tensor))) {
            FloatBuffer out = ((OnnxTensor) result.get(0)).getFloatBuffer();
            out.get(probability);
        }

        return boxesFromProbability(
            probability, netWidth, netHeight,
            (float) width / netWidth, (float) height / netHeight,
            width, height);
    }

    private static int roundToStride(double value) {
        int rounded = (int) Math.round(value / DET_STRIDE) * DET_STRIDE;
        return Math.max(DET_STRIDE, rounded);
    }

    /**
     * DB post-processing. PaddleOCR runs findContours plus minAreaRect;
     * this walks connected components and keeps the axis-aligned bound,
     * which is the same set of regions and is all the Dart side's
     * {@code Rect}-based OCR interface can carry anyway.
     */
    private static List<int[]> boxesFromProbability(
            float[] probability, int netWidth, int netHeight,
            float scaleX, float scaleY, int originalWidth, int originalHeight) {
        int size = probability.length;
        int[] label = new int[size];
        // Each pixel is labelled as it is pushed, so it can be pushed at
        // most once and the stack can never exceed the pixel count.
        int[] stack = new int[size];
        List<int[]> boxes = new ArrayList<>();
        int component = 0;

        for (int start = 0; start < size; start++) {
            if (probability[start] <= DET_THRESH || label[start] != 0) {
                continue;
            }
            component++;
            int stackPointer = 0;
            stack[stackPointer++] = start;
            label[start] = component;

            int y0 = start / netWidth;
            int x0 = start - y0 * netWidth;
            int x1 = x0;
            int y1 = y0;
            double sum = 0;
            int count = 0;

            while (stackPointer > 0) {
                int current = stack[--stackPointer];
                int cy = current / netWidth;
                int cx = current - cy * netWidth;
                if (cx < x0) x0 = cx;
                if (cx > x1) x1 = cx;
                if (cy < y0) y0 = cy;
                if (cy > y1) y1 = cy;
                sum += probability[current];
                count++;

                if (cx > 0) {
                    int q = current - 1;
                    if (probability[q] > DET_THRESH && label[q] == 0) {
                        label[q] = component;
                        stack[stackPointer++] = q;
                    }
                }
                if (cx < netWidth - 1) {
                    int q = current + 1;
                    if (probability[q] > DET_THRESH && label[q] == 0) {
                        label[q] = component;
                        stack[stackPointer++] = q;
                    }
                }
                if (cy > 0) {
                    int q = current - netWidth;
                    if (probability[q] > DET_THRESH && label[q] == 0) {
                        label[q] = component;
                        stack[stackPointer++] = q;
                    }
                }
                if (cy < netHeight - 1) {
                    int q = current + netWidth;
                    if (probability[q] > DET_THRESH && label[q] == 0) {
                        label[q] = component;
                        stack[stackPointer++] = q;
                    }
                }
            }

            if (count == 0 || sum / count < DET_BOX_THRESH) {
                continue;
            }
            int boxWidth = x1 - x0 + 1;
            int boxHeight = y1 - y0 + 1;
            if (boxWidth < 3 || boxHeight < 3) {
                continue;
            }
            // Vatti unclip; for a rectangle the offset distance reduces
            // exactly to area * ratio / perimeter.
            double distance = (double) boxWidth * boxHeight * DET_UNCLIP_RATIO
                / (2.0 * (boxWidth + boxHeight));
            int left = (int) Math.max(0, Math.floor((x0 - distance) * scaleX));
            int top = (int) Math.max(0, Math.floor((y0 - distance) * scaleY));
            int right = (int) Math.min(originalWidth,
                Math.ceil((x1 + 1 + distance) * scaleX));
            int bottom = (int) Math.min(originalHeight,
                Math.ceil((y1 + 1 + distance) * scaleY));
            if (right - left < 2 || bottom - top < 2) {
                continue;
            }
            boxes.add(new int[]{left, top, right, bottom});
        }
        return boxes;
    }

    // ---------------------------------------------------------------
    // Geometry: fragment merging, grouping, reading order
    // ---------------------------------------------------------------

    private static final int SHAPE_HORIZONTAL = 0;
    private static final int SHAPE_VERTICAL = 1;
    private static final int SHAPE_AMBIGUOUS = 2;

    private static int shapeOf(int[] box) {
        int w = box[2] - box[0];
        int h = box[3] - box[1];
        if (h > w * 1.5) {
            return SHAPE_VERTICAL;
        }
        if (w > h * 1.5) {
            return SHAPE_HORIZONTAL;
        }
        return SHAPE_AMBIGUOUS;
    }

    private static float overlap(int a0, int a1, int b0, int b1) {
        int lo = Math.max(a0, b0);
        int hi = Math.min(a1, b1);
        if (hi <= lo) {
            return 0f;
        }
        return (float) (hi - lo) / Math.max(1, Math.min(a1 - a0, b1 - b0));
    }

    private static int gap(int a0, int a1, int b0, int b1) {
        return Math.max(0, Math.max(a0, b0) - Math.min(a1, b1));
    }

    /**
     * Join boxes that are pieces of one line or column. The detector
     * routinely cuts a trailing 「。」 or 「！」 loose from its column,
     * because the glyph sits low in its em box with a clear gap above.
     */
    private static List<int[]> mergeFragments(List<int[]> input) {
        List<int[]> boxes = new ArrayList<>(input);
        boolean changed = true;
        while (changed) {
            changed = false;
            outer:
            for (int i = 0; i < boxes.size(); i++) {
                for (int j = i + 1; j < boxes.size(); j++) {
                    int[] a = boxes.get(i);
                    int[] b = boxes.get(j);
                    int shapeA = shapeOf(a);
                    int shapeB = shapeOf(b);
                    int aw = a[2] - a[0];
                    int ah = a[3] - a[1];
                    int bw = b[2] - b[0];
                    int bh = b[3] - b[1];
                    boolean joined = false;

                    // Stacked and sharing an X band. The glyph advance in
                    // tategaki is about the column width, so the gap
                    // tolerance keys off width, not height. Two clearly
                    // horizontal boxes are excluded, or the stacked lines
                    // of a paragraph would all collapse into one.
                    if (shapeA != SHAPE_HORIZONTAL && shapeB != SHAPE_HORIZONTAL
                            && overlap(a[0], a[2], b[0], b[2]) > 0.5f
                            && gap(a[1], a[3], b[1], b[3]) < Math.max(aw, bw)) {
                        joined = true;
                    }
                    // Side by side and sharing a Y band.
                    if (!joined
                            && shapeA != SHAPE_VERTICAL && shapeB != SHAPE_VERTICAL
                            && overlap(a[1], a[3], b[1], b[3]) > 0.5f
                            && gap(a[0], a[2], b[0], b[2]) < Math.max(ah, bh)) {
                        joined = true;
                    }

                    if (joined) {
                        boxes.set(i, new int[]{
                            Math.min(a[0], b[0]), Math.min(a[1], b[1]),
                            Math.max(a[2], b[2]), Math.max(a[3], b[3])});
                        boxes.remove(j);
                        changed = true;
                        break outer;
                    }
                }
            }
        }
        return boxes;
    }

    /** Union-find grouping of lines into blocks (bubbles, paragraphs). */
    private static List<List<Integer>> groupBlocks(List<int[]> boxes, boolean[] vertical) {
        int n = boxes.size();
        int[] parent = new int[n];
        for (int i = 0; i < n; i++) {
            parent[i] = i;
        }
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                if (vertical[i] != vertical[j]) {
                    continue;
                }
                int[] a = boxes.get(i);
                int[] b = boxes.get(j);
                int aw = a[2] - a[0];
                int ah = a[3] - a[1];
                int bw = b[2] - b[0];
                int bh = b[3] - b[1];
                boolean near;
                if (vertical[i]) {
                    // Columns sit side by side, overlapping in Y.
                    near = overlap(a[1], a[3], b[1], b[3]) > 0.3f
                        && gap(a[0], a[2], b[0], b[2]) < 1.5f * Math.max(aw, bw);
                } else {
                    near = overlap(a[0], a[2], b[0], b[2]) > 0.3f
                        && gap(a[1], a[3], b[1], b[3]) < 1.2f * Math.max(ah, bh);
                }
                if (near) {
                    union(parent, i, j);
                }
            }
        }
        Map<Integer, List<Integer>> byRoot = new HashMap<>();
        for (int i = 0; i < n; i++) {
            List<Integer> bucket = byRoot.get(find(parent, i));
            if (bucket == null) {
                bucket = new ArrayList<>();
                byRoot.put(find(parent, i), bucket);
            }
            bucket.add(i);
        }
        return new ArrayList<>(byRoot.values());
    }

    private static int find(int[] parent, int x) {
        while (parent[x] != x) {
            parent[x] = parent[parent[x]];
            x = parent[x];
        }
        return x;
    }

    private static void union(int[] parent, int x, int y) {
        int rx = find(parent, x);
        int ry = find(parent, y);
        if (rx != ry) {
            parent[ry] = rx;
        }
    }

    /** Tategaki reads right to left; yokogaki reads top to bottom. */
    private static List<Integer> orderWithinBlock(
            List<Integer> group, List<int[]> boxes, boolean[] vertical) {
        List<Integer> ordered = new ArrayList<>(group);
        boolean isVertical = vertical[group.get(0)];
        Collections.sort(ordered, (x, y) -> isVertical
            ? Integer.compare(boxes.get(y)[2], boxes.get(x)[2])
            : Integer.compare(boxes.get(x)[1], boxes.get(y)[1]));
        return ordered;
    }

    /** Blocks themselves: a tategaki page runs right to left. */
    private static List<List<Integer>> orderBlocks(
            List<List<Integer>> groups, List<int[]> boxes, boolean[] vertical) {
        List<List<Integer>> ordered = new ArrayList<>(groups);
        Collections.sort(ordered, (g1, g2) -> {
            boolean v1 = vertical[g1.get(0)];
            boolean v2 = vertical[g2.get(0)];
            if (v1 && v2) {
                int r1 = Integer.MIN_VALUE;
                int r2 = Integer.MIN_VALUE;
                for (int i : g1) r1 = Math.max(r1, boxes.get(i)[2]);
                for (int i : g2) r2 = Math.max(r2, boxes.get(i)[2]);
                if (r1 != r2) {
                    return Integer.compare(r2, r1);
                }
            }
            int t1 = Integer.MAX_VALUE;
            int t2 = Integer.MAX_VALUE;
            for (int i : g1) t1 = Math.min(t1, boxes.get(i)[1]);
            for (int i : g2) t2 = Math.min(t2, boxes.get(i)[1]);
            if (t1 != t2) {
                return Integer.compare(t1, t2);
            }
            int l1 = Integer.MAX_VALUE;
            int l2 = Integer.MAX_VALUE;
            for (int i : g1) l1 = Math.min(l1, boxes.get(i)[0]);
            for (int i : g2) l2 = Math.min(l2, boxes.get(i)[0]);
            return Integer.compare(l1, l2);
        });
        return ordered;
    }

    // ---------------------------------------------------------------
    // Recognition
    // ---------------------------------------------------------------

    private String[] recognize(Bitmap bitmap, List<int[]> boxes, boolean[] vertical)
            throws Exception {
        int n = boxes.size();
        String[] texts = new String[n];

        // Batch by aspect ratio, as PaddleOCR does, so a short line is not
        // padded out to the width of the longest column in its batch.
        Integer[] order = new Integer[n];
        for (int i = 0; i < n; i++) {
            order[i] = i;
        }
        Arrays.sort(order, (x, y) -> Float.compare(ratioOf(boxes.get(x), vertical[x]),
                                                   ratioOf(boxes.get(y), vertical[y])));

        for (int start = 0; start < n; start += REC_BATCH) {
            int end = Math.min(n, start + REC_BATCH);
            int count = end - start;

            float maxRatio = 0f;
            for (int k = start; k < end; k++) {
                maxRatio = Math.max(maxRatio, ratioOf(boxes.get(order[k]), vertical[order[k]]));
            }
            int batchWidth = (int) Math.ceil(maxRatio * REC_HEIGHT / 8.0) * 8;
            batchWidth = Math.max(REC_MIN_WIDTH, Math.min(REC_MAX_WIDTH, batchWidth));

            int plane = REC_HEIGHT * batchWidth;
            // Left as zeros outside each line's own width: zero is the
            // normalised mid-grey PaddleOCR pads with.
            float[] batch = new float[count * 3 * plane];

            for (int k = start; k < end; k++) {
                int index = order[k];
                int[] box = boxes.get(index);
                int cropWidth = box[2] - box[0];
                int cropHeight = box[3] - box[1];
                int[] pixels = new int[cropWidth * cropHeight];
                bitmap.getPixels(pixels, 0, cropWidth, box[0], box[1], cropWidth, cropHeight);
                fillRecognitionSlot(batch, k - start, batchWidth, plane,
                    pixels, cropWidth, cropHeight, vertical[index]);
            }

            try (OnnxTensor tensor = OnnxTensor.createTensor(
                    environment, FloatBuffer.wrap(batch),
                    new long[]{count, 3, REC_HEIGHT, batchWidth});
                 OrtSession.Result result = recSession.run(
                     Collections.singletonMap(recInputName(), tensor))) {
                // By name, not by position: the two heads were appended
                // to the graph by tools/fetch-ppocr-models.sh and their
                // order is not something to depend on here.
                OnnxTensor indicesTensor = (OnnxTensor) result.get("ctc_indices")
                    .orElseThrow(() -> new IllegalStateException(
                        "recognition model has no ctc_indices output"));
                OnnxTensor probabilityTensor = (OnnxTensor) result.get("ctc_probs")
                    .orElseThrow(() -> new IllegalStateException(
                        "recognition model has no ctc_probs output"));
                int steps = (int) indicesTensor.getInfo().getShape()[1];
                LongBuffer indices = indicesTensor.getLongBuffer();
                FloatBuffer probabilities = probabilityTensor.getFloatBuffer();
                long[] indexData = new long[count * steps];
                indices.get(indexData);
                float[] probabilityData = new float[count * steps];
                probabilities.get(probabilityData);

                for (int slot = 0; slot < count; slot++) {
                    texts[order[start + slot]] =
                        decodeCtc(indexData, probabilityData, slot, steps);
                }
            }
        }
        return texts;
    }

    private static float ratioOf(int[] box, boolean vertical) {
        float w = box[2] - box[0];
        float h = box[3] - box[1];
        // Rotating a column swaps its extents before the aspect matters.
        return vertical ? h / Math.max(1f, w) : w / Math.max(1f, h);
    }

    /**
     * Resample one crop into its slot of the batch tensor, rotating a
     * tategaki column so its top edge becomes the left edge, and
     * normalising to BGR (x / 127.5 - 1) in one pass.
     */
    private static void fillRecognitionSlot(
            float[] batch, int slot, int batchWidth, int plane,
            int[] pixels, int cropWidth, int cropHeight, boolean vertical) {
        int virtualWidth = vertical ? cropHeight : cropWidth;
        int virtualHeight = vertical ? cropWidth : cropHeight;

        int targetWidth = Math.max(1, Math.min(batchWidth,
            Math.round((float) virtualWidth / virtualHeight * REC_HEIGHT)));
        float scaleX = (float) virtualWidth / targetWidth;
        float scaleY = (float) virtualHeight / REC_HEIGHT;
        int base = slot * 3 * plane;

        for (int dy = 0; dy < REC_HEIGHT; dy++) {
            float vy = (dy + 0.5f) * scaleY - 0.5f;
            int vy0 = (int) Math.floor(vy);
            float fy = vy - vy0;
            for (int dx = 0; dx < targetWidth; dx++) {
                float vx = (dx + 0.5f) * scaleX - 0.5f;
                int vx0 = (int) Math.floor(vx);
                float fx = vx - vx0;

                int c00 = virtualPixel(pixels, cropWidth, cropHeight, vertical,
                    vx0, vy0, virtualWidth, virtualHeight);
                int c10 = virtualPixel(pixels, cropWidth, cropHeight, vertical,
                    vx0 + 1, vy0, virtualWidth, virtualHeight);
                int c01 = virtualPixel(pixels, cropWidth, cropHeight, vertical,
                    vx0, vy0 + 1, virtualWidth, virtualHeight);
                int c11 = virtualPixel(pixels, cropWidth, cropHeight, vertical,
                    vx0 + 1, vy0 + 1, virtualWidth, virtualHeight);

                int offset = dy * batchWidth + dx;
                for (int channel = 0; channel < 3; channel++) {
                    int shift = channel * 8;
                    float top = ((c00 >> shift) & 0xFF) * (1 - fx)
                        + ((c10 >> shift) & 0xFF) * fx;
                    float bottom = ((c01 >> shift) & 0xFF) * (1 - fx)
                        + ((c11 >> shift) & 0xFF) * fx;
                    float value = top * (1 - fy) + bottom * fy;
                    batch[base + channel * plane + offset] = value / 127.5f - 1f;
                }
            }
        }
    }

    private static int virtualPixel(int[] pixels, int cropWidth, int cropHeight,
                                    boolean vertical, int vx, int vy,
                                    int virtualWidth, int virtualHeight) {
        // Clamp in the virtual frame first, so the mapping below can
        // never land outside the crop.
        if (vx < 0) vx = 0; else if (vx >= virtualWidth) vx = virtualWidth - 1;
        if (vy < 0) vy = 0; else if (vy >= virtualHeight) vy = virtualHeight - 1;
        int ox;
        int oy;
        if (vertical) {
            // Counter-clockwise: the column's top edge becomes the left
            // edge, so the first glyph is read first.
            ox = cropWidth - 1 - vy;
            oy = vx;
        } else {
            ox = vx;
            oy = vy;
        }
        return pixels[oy * cropWidth + ox];
    }

    /**
     * Greedy CTC: drop blanks, collapse runs, map through the table.
     * Returns null for a line whose mean confidence falls below
     * {@link #REC_DROP_SCORE}, which the caller treats as no text.
     */
    private String decodeCtc(long[] indexData, float[] probabilityData,
                             int slot, int steps) {
        StringBuilder builder = new StringBuilder();
        int previous = 0;
        int offset = slot * steps;
        double sum = 0;
        int emitted = 0;
        for (int t = 0; t < steps; t++) {
            int index = (int) indexData[offset + t];
            if (index != 0 && index != previous && index < charTable.length) {
                builder.append(charTable[index]);
                sum += probabilityData[offset + t];
                emitted++;
            }
            previous = index;
        }
        if (emitted == 0 || sum / emitted < REC_DROP_SCORE) {
            return null;
        }
        return builder.toString();
    }

    // ---------------------------------------------------------------
    // Model loading
    // ---------------------------------------------------------------

    private String detInputName() throws Exception {
        return detSession.getInputNames().iterator().next();
    }

    private String recInputName() throws Exception {
        return recSession.getInputNames().iterator().next();
    }

    private void ensureLoaded() throws Exception {
        if (detSession != null && recSession != null && charTable != null) {
            return;
        }
        environment = OrtEnvironment.getEnvironment();

        File detFile = extractAsset(DET_MODEL);
        File recFile = extractAsset(REC_MODEL);

        OrtSession.SessionOptions options = new OrtSession.SessionOptions();
        // The bridge already serialises calls on one thread; let ORT use
        // the cores for a single inference instead.
        options.setIntraOpNumThreads(
            Math.max(1, Math.min(4, Runtime.getRuntime().availableProcessors())));
        options.setOptimizationLevel(
            OrtSession.SessionOptions.OptLevel.ALL_OPT);

        detSession = environment.createSession(detFile.getAbsolutePath(), options);
        recSession = environment.createSession(recFile.getAbsolutePath(), options);

        String[] keys = readKeys();
        // PaddleOCR's BaseRecLabelDecode: blank first, space appended
        // last, giving the 18710 classes the model emits.
        charTable = new String[keys.length + 2];
        charTable[0] = "";
        System.arraycopy(keys, 0, charTable, 1, keys.length);
        charTable[keys.length + 1] = " ";
    }

    private String[] readKeys() throws IOException {
        try (InputStream in = appContext.getAssets().open(ASSET_DIR + "/" + KEYS_FILE)) {
            java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
            byte[] buffer = new byte[8192];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            return new String(out.toByteArray(), StandardCharsets.UTF_8).split("\n", -1);
        }
    }

    /**
     * ORT wants a path it can map, and APK assets are compressed. Copy
     * once into files/ocr and reuse; a size mismatch means the app was
     * updated with new models, so rewrite.
     */
    private File extractAsset(String name) throws IOException {
        File directory = new File(appContext.getFilesDir(), ASSET_DIR);
        if (!directory.exists() && !directory.mkdirs()) {
            throw new IOException("could not create " + directory);
        }
        File target = new File(directory, name);
        long assetSize;
        try (InputStream probe = appContext.getAssets().open(ASSET_DIR + "/" + name)) {
            assetSize = 0;
            byte[] buffer = new byte[8192];
            int read;
            while ((read = probe.read(buffer)) != -1) {
                assetSize += read;
            }
        }
        if (target.exists() && target.length() == assetSize) {
            return target;
        }
        try (InputStream in = appContext.getAssets().open(ASSET_DIR + "/" + name);
             OutputStream out = new FileOutputStream(target)) {
            byte[] buffer = new byte[65536];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
        }
        return target;
    }

    private void closeQuietly() {
        try {
            if (detSession != null) {
                detSession.close();
            }
        } catch (Exception ignored) {
        }
        try {
            if (recSession != null) {
                recSession.close();
            }
        } catch (Exception ignored) {
        }
        detSession = null;
        recSession = null;
    }

    private void succeed(MethodChannel.Result result, Object value) {
        mainHandler.post(() -> result.success(value));
    }

    private void fail(MethodChannel.Result result, String op, Throwable e) {
        mainHandler.post(() -> result.error("OcrBridge", op + " failed: " + e, null));
    }
}
