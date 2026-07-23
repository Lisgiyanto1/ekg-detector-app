// android/build.gradle.kts

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Mengembalikan ke standar resmi Flutter agar APK mendarat tepat di radar pencarian
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val subprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(subprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    // Fungsi pembungkus konfigurasi agar aman dari error siklus evaluasi Gradle
    val configureKotlinTasks = {
        if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
                val javaVersion = android?.compileOptions?.targetCompatibility
                
                compilerOptions {
                    if (javaVersion != null) {
                        when (javaVersion) {
                            JavaVersion.VERSION_1_8 -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8)
                            JavaVersion.VERSION_11 -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
                            JavaVersion.VERSION_17 -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                            else -> jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
                        }
                    }
                }
            }
        }
    }

    // JIKA proyek sudah dievaluasi oleh 'evaluationDependsOn', langsung eksekusi.
    // JIKA BELUM, masukkan ke antrean afterEvaluate.
    if (project.state.executed) {
        configureKotlinTasks()
    } else {
        project.afterEvaluate {
            configureKotlinTasks()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}