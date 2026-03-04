plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin — processes google-services.json
    id("com.google.gms.google-services")
}

android {
    namespace = "com.turfspot.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.turfspot.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Using debug signing config so the APK is installable on mobile devices for testing.
            signingConfig = signingConfigs.getByName("debug")
            
            isMinifyEnabled = false
isShrinkResources = false

        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Import the Firebase BoM — manages all Firebase SDK versions automatically
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

    // Firebase Analytics (included by default; required for Firebase to initialise)
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Cloud Messaging — for push notifications
    implementation("com.google.firebase:firebase-messaging")
}
