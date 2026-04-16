import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

plugins {
    // 🔥 Firebase Google Services plugin (correct place)
    id("com.google.gms.google-services") version "4.4.4" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 📦 Custom build directory (your original setup preserved)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

// 📦 Apply custom build dirs to subprojects
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ⚙️ Ensure :app builds first
subprojects {
    project.evaluationDependsOn(":app")
}

// 🧹 Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}