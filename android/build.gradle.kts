allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Force compatible androidx versions for AGP 8.7.0.
    // activity:1.12.4 and core:1.18.0 require AGP 8.9.1+ which needs Gradle 8.11.1+.
    // Pinning to stable versions that work with current Gradle 8.10.2 / AGP 8.7.0.
    configurations.configureEach {
        resolutionStrategy.force(
            "androidx.activity:activity:1.9.0",
            "androidx.activity:activity-ktx:1.9.0",
            "androidx.core:core:1.13.1",
            "androidx.core:core-ktx:1.13.1"
        )
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
