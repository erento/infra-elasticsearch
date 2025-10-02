def projectBaseName = "infra-elasticsearch"
def elasticsearch_version = "7.5.1-erento-002"

def imageName = "${projectBaseName}:${elasticsearch_version}"

node {
    stage("checkout") {
        checkout scm
    }

    stage("bake and push service image") {
        def myImage = docker.build("eu.gcr.io/erento-docker/${imageName}", ".")
        myImage.push()
        myImage.push('latest')
        milestone(label: "image baked and pushed")
    }
}
