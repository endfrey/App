# Flutter
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.app.** { *; }

# Firebase Analytics
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Stripe Android
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Needed for Push Provisioning (ตาม error ของมึง)
-keep class com.stripe.android.pushProvisioning.** { *; }

# Gson / JSON serialization (บาง package อาจใช้)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# OkHttp3 (Stripe ใช้)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Kotlin metadata
-keep class kotlin.Metadata { *; }
