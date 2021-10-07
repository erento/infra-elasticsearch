projectBaseName = "infra-elasticsearch"

shortLabel = projectBaseName.size() >= 10 ? projectBaseName.substring(0, 10) : projectBaseName
buildLabel = "${shortLabel}-${UUID.randomUUID().toString()}"

imageVersion = "001"
elasticsearchVersion = "7.15.0"
imageName = "${projectBaseName}:${elasticsearchVersion}-${imageVersion}"
imageNameWithPath = "eu.gcr.io/campanda-docker/${imageName}"
maxCommits = 10

defaultEnvList = [
    envVar(key: "IMAGE", value: imageNameWithPath),
]

podTemplate(label: "global") {
    podTemplate(
        label: buildLabel,
        containers: [
            containerTemplate(name: "kaniko", image: "gcr.io/kaniko-project/executor:debug-v1.3.0", ttyEnabled: true, command: "/busybox/cat",
                envVars: [
                    containerEnvVar(key: "GOOGLE_APPLICATION_CREDENTIALS", value: "/secret/campanda-docker-account.json")
                ]
            ),
        ],
        envVars: defaultEnvList,
        nodeSelector: "type=worker",
        volumes: [
            secretVolume(secretName: "campanda-docker-account", mountPath: "/secret"),
        ]
    ) {
        node(buildLabel) {
            stage("checkout") {
                gitCheckout(maxCommits)
            }

            stage("build image & push") {
                container(name: "kaniko", shell: "/busybox/sh") {
                    sh """#!/busybox/sh
                        /kaniko/executor --dockerfile `pwd`/Dockerfile --cache=true --context `pwd` --destination=$IMAGE
                    """
                }
            }
        }
    }
}
