allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
    
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                if (project.android.hasProperty('compileSdkVersion')) {
                    compileSdkVersion 34
                } else {
                    compileSdk 34
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}