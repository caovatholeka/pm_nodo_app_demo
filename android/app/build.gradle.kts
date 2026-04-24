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
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // comment khi develop
    //   signingConfigs {
    //       create("release") {
    //           keyAlias = keystoreProperties.getProperty("keyAlias")
    //           keyPassword = keystoreProperties.getProperty("keyPassword")
    //           storeFile = file(keystoreProperties.getProperty("storeFile"))
    //           storePassword = keystoreProperties.getProperty("storePassword")
    //           storeType = "JKS"
    //       }
    //   }

    // debug : develop , release : build abb file
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // release/debug
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.23")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

configurations.all {
    resolutionStrategy {
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.core:core:1.13.1")
    }
}
