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
}

subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate

        val getNamespaceMethod = androidExtension::class.java.methods
            .firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
        val setNamespaceMethod = androidExtension::class.java.methods
            .firstOrNull { it.name == "setNamespace" && it.parameterCount == 1 }

        if (getNamespaceMethod == null || setNamespaceMethod == null) {
            return@afterEvaluate
        }

        val currentNamespace = getNamespaceMethod.invoke(androidExtension) as? String
        if (!currentNamespace.isNullOrBlank()) {
            return@afterEvaluate
        }

        val sanitizedProjectName = project.name
            .lowercase()
            .replace(Regex("[^a-z0-9_]"), "_")
        val fallbackNamespace = "com.generated.$sanitizedProjectName"
        setNamespaceMethod.invoke(androidExtension, fallbackNamespace)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
