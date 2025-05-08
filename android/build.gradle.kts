allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
    // Also clean Kotlin incremental compilation caches
    delete(fileTree("${rootProject.projectDir}") {
        include("**/*.kotlin_module")
        include("**/*.kotlin_builtins")
        include("**/*.kotlin_metadata")
        include("**/*.kotlin_incremental")
    })
}
