import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Gradle de Flutter doit venir après les plugins Android et Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "tn.isetbizerte.tp3_channels"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "tn.isetbizerte.tp3_channels"
        minSdk = 26        // Android 8.0 : simplifie le code de vibration (étape 2)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signature "debug" pour pouvoir lancer `flutter run --release` pendant le TP.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Étape 4 : coroutines (Dispatchers.IO / Dispatchers.Main)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.1")
}
