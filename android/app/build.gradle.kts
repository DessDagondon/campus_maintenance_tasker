plugins {
    id("com.android.application")
    id("kotlin-android")
    // 🔥 Add Firebase plugin
    id("com.google.gms.google-services")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.arisenlab.campusmaintenancetasker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.arisenlab.campusmaintenancetasker"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔥 Firebase BoM (manages all versions automatically)
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))

    // ✅ Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // ✅ Firebase Realtime Database
    implementation("com.google.firebase:firebase-database")
}