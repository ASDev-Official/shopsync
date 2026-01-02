import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.aadishsamir.shopsync"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            register("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it.toString()) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.aadishsamir.shopsync"
        minSdk = 29
        targetSdk = 36
        
        // Enable Credential Manager for Google Sign-In
        manifestPlaceholders["credentialManagerEnabled"] = true
    }

    flavorDimensions.add("platform")
    productFlavors {
        create("phone") {
            val phoneBaseVersionCode = 300000000
            val phoneVersionCode = 11
            dimension = "platform"
            manifestPlaceholders.clear()
            versionName = "5.1.1-phone"
            versionCode = phoneBaseVersionCode + phoneVersionCode
        }
        create("wear") {
            val wearBaseVersionCode = 400000000
            val wearVersionCode = 8
            manifestPlaceholders.clear()
            dimension = "platform"
            versionName = "1.3.1-wear"
            versionCode = wearBaseVersionCode + wearVersionCode
        }
    }

    buildTypes {
        named("release") {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
