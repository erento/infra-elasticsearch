projectBaseName = "infra-elasticsearch"
elasticsearch_version = "7.5.1-001"

imageName = "${projectBaseName}:${elasticsearch_version}"

node {
    stage("checkout") {
        checkout scm
    }

    stage("bake and push service image") {
        def myImage = docker.build("eu.gcr.io/campanda-docker/${imageName}", ".")
        myImage.push()
        myImage.push('latest')
        milestone(label: "image baked and pushed")
    }
}
