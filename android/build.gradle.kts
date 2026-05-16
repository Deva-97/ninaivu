import org.gradle.api.tasks.compile.JavaCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    // Keep third-party Android plugin warnings from polluting the terminal.
    tasks.withType<JavaCompile>().configureEach {
        options.isWarnings = false
        options.isDeprecation = false
        options.compilerArgs.addAll(
            listOf(
                "-nowarn",
                "-Xlint:-unchecked",
                "-Xlint:-deprecation",
            )
        )
    }

    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            suppressWarnings.set(true)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
