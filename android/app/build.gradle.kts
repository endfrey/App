plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.wstore"
    compileSdk = 36 // ใช้ 36 เพื่อแก้ AAR metadata issue

    defaultConfig {
        applicationId = "com.example.wstore"
        minSdk = flutter.minSdkVersion // แนะนำ 21 ขึ้นไป
        targetSdk = 36 // ตรงกับ compileSdk
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false // ปิดชั่วคราวเพื่อ build ผ่าน
            isShrinkResources = false

            signingConfig = signingConfigs.getByName("debug") // เปลี่ยนเป็น release key เมื่อปล่อยจริง

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // ✅ แก้ duplicate class ของ Play Core
    configurations.all {
        // ตัด module core-common ออก เพื่อป้องกัน duplicate class
        exclude(group = "com.google.android.play", module = "core-common")

        resolutionStrategy {
            // บังคับให้ใช้ core version 1.10.3 ตัวเดียว
            force("com.google.android.play:core:1.10.3")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))
    implementation("com.google.firebase:firebase-analytics")

    // Stripe SDK
    implementation("com.stripe:stripe-android:20.36.0")

    // AndroidX
    implementation("androidx.activity:activity-ktx:1.10.1")
    implementation("androidx.activity:activity-compose:1.10.1")

    // Play Core สำหรับ Flutter deferred components
    implementation("com.google.android.play:core:1.10.3") {
        // ป้องกันการดึง core-common ซ้ำ
        exclude(group = "com.google.android.play", module = "core-common")
    }
}
