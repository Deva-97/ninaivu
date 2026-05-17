import java.util.Properties
import org.gradle.api.GradleException
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystoreFile = keystorePropertiesFile.exists()

if (hasReleaseKeystoreFile) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun Properties.requireValue(key: String): String? =
    getProperty(key)?.takeIf { it.isNotBlank() }

val releaseStoreFile =
    keystoreProperties.requireValue("storeFile")?.let(::file)

val hasReleaseKeystore =
    listOf("keyAlias", "keyPassword", "storePassword", "storeFile").all {
        keystoreProperties.requireValue(it) != null
    } && releaseStoreFile?.exists() == true

val isReleaseTaskRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (isReleaseTaskRequested && !hasReleaseKeystore) {
    throw GradleException(
        "Release signing is not configured correctly. " +
            "Update android/key.properties with a valid keystore path and credentials before building a release."
    )
}

android {
    namespace = "com.devendiran.ninaivu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.devendiran.ninaivu"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = releaseStoreFile
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
