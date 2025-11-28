# Keep TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.Delegate { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep common Flutter plugin classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
