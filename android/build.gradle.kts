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

fun org.gradle.api.Project.applyNamespaceFallbackIfMissing() {
    val androidExtension = extensions.findByName("android") ?: return

    val getNamespaceMethod = androidExtension::class.java.methods
        .firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
    val setNamespaceMethod = androidExtension::class.java.methods
        .firstOrNull { it.name == "setNamespace" && it.parameterCount == 1 }

    if (getNamespaceMethod == null || setNamespaceMethod == null) {
        return
    }

    val currentNamespace = getNamespaceMethod.invoke(androidExtension) as? String
    if (!currentNamespace.isNullOrBlank()) {
        return
    }

    val sanitizedProjectName = name
        .lowercase()
        .replace(Regex("[^a-z0-9_]"), "_")
    val fallbackNamespace = "com.generated.$sanitizedProjectName"
    setNamespaceMethod.invoke(androidExtension, fallbackNamespace)
}

fun org.gradle.api.Project.applyJvmTargetCompatibilityIfAndroid() {
    val androidExtension = extensions.findByName("android") ?: return

    val getCompileOptionsMethod = androidExtension::class.java.methods
        .firstOrNull { it.name == "getCompileOptions" && it.parameterCount == 0 }
    val compileOptions = getCompileOptionsMethod?.invoke(androidExtension)

    if (compileOptions != null) {
        compileOptions::class.java.methods
            .firstOrNull { it.name == "setSourceCompatibility" && it.parameterCount == 1 }
            ?.invoke(compileOptions, JavaVersion.VERSION_17)
        compileOptions::class.java.methods
            .firstOrNull { it.name == "setTargetCompatibility" && it.parameterCount == 1 }
            ?.invoke(compileOptions, JavaVersion.VERSION_17)
    }

    val getKotlinOptionsMethod = androidExtension::class.java.methods
        .firstOrNull { it.name == "getKotlinOptions" && it.parameterCount == 0 }
    val kotlinOptions = getKotlinOptionsMethod?.invoke(androidExtension)

    if (kotlinOptions != null) {
        kotlinOptions::class.java.methods
            .firstOrNull { it.name == "setJvmTarget" && it.parameterCount == 1 }
            ?.invoke(kotlinOptions, "17")
    }
}

subprojects {
    plugins.withId("com.android.library") {
        applyNamespaceFallbackIfMissing()
        applyJvmTargetCompatibilityIfAndroid()
    }
    plugins.withId("com.android.application") {
        applyNamespaceFallbackIfMissing()
        applyJvmTargetCompatibilityIfAndroid()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
