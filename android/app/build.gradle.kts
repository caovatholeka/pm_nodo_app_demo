import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nodo.pm_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"


    defaultConfig {
        applicationId = "com.nodo.pm_app"
        minSdk = flutter.minSdkVersion //flutter.minSdkVersion
        targetSdk = 35
        versionCode = 7
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // signingConfigs {
    //     create("release") {
    //         keyAlias = keystoreProperties.getProperty("keyAlias")
    //         keyPassword = keystoreProperties.getProperty("keyPassword")
    //         storeFile = file(keystoreProperties.getProperty("storeFile"))
    //         storePassword = keystoreProperties.getProperty("storePassword")
    //     }
    // }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // release
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.23")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
