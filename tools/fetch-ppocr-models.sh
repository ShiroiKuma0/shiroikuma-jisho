#!/usr/bin/env bash
# Fetch and prepare the PP-OCRv6 ONNX models that back the on-device OCR
# engine, writing them into android/app/src/main/assets/ocr/.
#
# Run this only to re-derive the committed assets (a model bump, or an
# audit that the binaries match upstream). A normal build needs nothing
# from here -- the prepared assets are committed.
#
# Source:  https://huggingface.co/PaddlePaddle/PP-OCRv6_{small_det,small_rec}_onnx
# Licence: Apache-2.0 (code and weights alike) -- see assets/licenses/.
#
# Two departures from the stock upstream artifacts, both deliberate:
#
#  1. The recognition graph gets ArgMax + ReduceMax appended to its CTC
#     head. Stock, it emits [N, T, 18710] floats -- ~3 MB per text line
#     that JNI would have to marshal for no reason, since greedy CTC
#     decoding consumes only the per-timestep argmax and its probability.
#     PaddleOCR's own CTCLabelDecode does exactly this reduction in
#     Python, so the result is identical, ~9000x smaller.
#  2. The character dictionary is lifted out of inference.yml into a
#     plain UTF-8 file, one entry per line, so Java need not parse YAML.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/android/app/src/main/assets/ocr"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> workspace: $WORK"
python3 -m venv "$WORK/venv"
"$WORK/venv/bin/pip" install --quiet onnx pyyaml

for repo in PP-OCRv6_small_det_onnx PP-OCRv6_small_rec_onnx; do
    mkdir -p "$WORK/$repo"
    for f in inference.onnx inference.yml; do
        echo "==> downloading $repo/$f"
        curl -sSLf --retry 3 -o "$WORK/$repo/$f" \
            "https://huggingface.co/PaddlePaddle/$repo/resolve/main/$f"
    done
done

mkdir -p "$OUT_DIR"
WORK="$WORK" OUT_DIR="$OUT_DIR" "$WORK/venv/bin/python" - <<'PY'
import os, onnx, yaml
from onnx import helper, TensorProto

work, out = os.environ["WORK"], os.environ["OUT_DIR"]

# Detection graph is used as published.
det = onnx.load(f"{work}/PP-OCRv6_small_det_onnx/inference.onnx")
onnx.save(det, f"{out}/ppocrv6_det.onnx")

# Recognition graph: reduce the CTC head in-graph (see header).
rec = onnx.load(f"{work}/PP-OCRv6_small_rec_onnx/inference.onnx")
logits = rec.graph.output[0].name
rec.graph.node.append(helper.make_node(
    "ArgMax", [logits], ["ctc_indices"], name="ctc_argmax", axis=2, keepdims=0))
rec.graph.node.append(helper.make_node(
    "ReduceMax", [logits], ["ctc_probs"], name="ctc_reducemax", axes=[2], keepdims=0))
del rec.graph.output[:]
rec.graph.output.extend([
    helper.make_tensor_value_info("ctc_indices", TensorProto.INT64, ["N", "T"]),
    helper.make_tensor_value_info("ctc_probs", TensorProto.FLOAT, ["N", "T"]),
])
onnx.checker.check_model(rec)
onnx.save(rec, f"{out}/ppocrv6_rec.onnx")

# Character dictionary. Index 0 is the CTC blank and the trailing space
# is appended by the decoder, matching PaddleOCR's BaseRecLabelDecode;
# this file holds only the real entries, in order.
cfg = yaml.safe_load(open(f"{work}/PP-OCRv6_small_rec_onnx/inference.yml", encoding="utf-8"))
keys = [str(c) for c in cfg["PostProcess"]["character_dict"]]
assert all(k and "\n" not in k for k in keys), "dictionary entry breaks the line format"
with open(f"{out}/ppocrv6_keys.txt", "w", encoding="utf-8") as fh:
    fh.write("\n".join(keys))
print(f"    det  {os.path.getsize(out+'/ppocrv6_det.onnx')/1e6:.1f} MB")
print(f"    rec  {os.path.getsize(out+'/ppocrv6_rec.onnx')/1e6:.1f} MB")
print(f"    keys {len(keys)} entries -> {len(keys)+2} classes with blank and space")
PY
echo "==> wrote $OUT_DIR"
