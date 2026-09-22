import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.controlhorario.control_horario"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.controlhorario.control_horario"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val releaseSigningPropertiesFile = rootProject.file("release-signing.properties")
    val releaseSigningProperties = Properties()
    val isReleaseBuild = gradle.startParameter.taskNames.any { taskName ->
        taskName.contains("release", ignoreCase = true)
    }

    if (isReleaseBuild) {
        if (!releaseSigningPropertiesFile.isFile) {
            throw GradleException(
                "Release signing configuration is missing: create release-signing.properties."
            )
        }

        releaseSigningPropertiesFile.inputStream().use(releaseSigningProperties::load)
        val requiredSigningProperties = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        val missingSigningProperties = requiredSigningProperties.filter {
            releaseSigningProperties.getProperty(it).isNullOrBlank()
        }
        if (missingSigningProperties.isNotEmpty()) {
            throw GradleException(
                "Release signing configuration is incomplete: " +
                    missingSigningProperties.joinToString(", ")
            )
        }

        val releaseKeystore = rootProject.file(releaseSigningProperties.getProperty("storeFile"))
        if (!releaseKeystore.isFile) {
            throw GradleException("Release signing keystore is missing: ${releaseKeystore.path}")
        }
    }

    signingConfigs {
        create("release") {
            if (releaseSigningPropertiesFile.isFile) {
                if (releaseSigningProperties.isEmpty) {
                    releaseSigningPropertiesFile.inputStream().use(releaseSigningProperties::load)
                }
                storeFile = rootProject.file(releaseSigningProperties.getProperty("storeFile"))
                storePassword = releaseSigningProperties.getProperty("storePassword")
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Configure android/release-signing.properties with local signing values.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
