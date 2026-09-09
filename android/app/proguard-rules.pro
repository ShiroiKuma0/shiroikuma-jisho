# R8 full mode (the only mode in AGP 9; the old AGP 7 build ran compat
# mode) strips Room's generated *_Impl database classes, which Room
# loads reflectively via Class.forName(name + "_Impl"). androidx.work's
# WorkDatabase was the first casualty: the process died in
# InitializationProvider before Flutter even started (2026-07-25,
# 1.4.0+27 on the Palma). Keep every RoomDatabase subclass by name.
-keep class * extends androidx.room.RoomDatabase { <init>(); }

# libvlcjni.so resolves Java classes by name from JNI_OnLoad
# (FindClass on org.videolan.libvlc.interfaces.IMedia$Track failed as
# UnsatisfiedLinkError on 1.4.0+31 -- player dead). JNI lookups are
# invisible to R8; keep the libVLC Java surface intact by name.
-keep class org.videolan.libvlc.** { *; }

# ONNX Runtime's Java surface is bound from libonnxruntime4j_jni.so by
# name (OnnxTensor, OrtSession and the enums their JNI constructs), and
# JNI lookups are invisible to R8 -- the same failure mode that took out
# libVLC. Keep the whole ai.onnxruntime package.
-keep class ai.onnxruntime.** { *; }
