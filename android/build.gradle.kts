// All projects repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directories
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Buildscript for classpath dependencies
buildscript {
    repositories {
        google()      // <-- Required to resolve com.google.gms:google-services
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0") // Android Gradle plugin
      // Google services plugin
    }
}
