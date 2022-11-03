/**
 * JetBrains Space Automation
 * This Kotlin-script file lets you automate build activities
 * For more info, see https://www.jetbrains.com/help/space/automation.html
 */

job("Build and publish activemq Docker image") {

    docker {
        beforeBuildScript {
            // Create an env variable BRANCH,
            // use env var to get full branch name,
            // leave only the branch name without the 'refs/heads/' path
            content = """
                export BRANCH=${'$'}(echo ${'$'}JB_SPACE_GIT_BRANCH | cut -d'/' -f 3)
            """
        }
        build {
            context = "."
            file = "./Dockerfile"
            labels["vendor"] = "GeoCat B.V."
        }

        push("geocat.registry.jetbrains.space/p/jrc-inspire-portal/docker/activemq") {
            // Use the BRANCH and JB_SPACE_EXECUTION_NUMBER env vars
            tags("\$BRANCH", "\$BRANCH-\$JB_SPACE_EXECUTION_NUMBER")
        }
    }


    container(
        displayName="Push Docker image in GeoCat Docker repository",
        image="geocat.registry.jetbrains.space/p/jrc-inspire-portal/geocat-systems/crane:main"
    ) {
        env["GEOCAT_DOCKER_REGISTRY_URL"] = "docker-registry.geocat.net:5000"
        env["GEOCAT_DOCKER_REGISTRY_USER"] = Params("geocat_docker_registry_user")
        env["GEOCAT_DOCKER_REGISTRY_PASSWORD"] = Secrets("geocat_docker_registry_password")

        shellScript {
            content = """
            	BRANCH=${'$'}(echo ${'$'}JB_SPACE_GIT_BRANCH | cut -d'/' -f 3)
                crane auth login geocat.registry.jetbrains.space -u ${'$'}JB_SPACE_CLIENT_ID -p ${'$'}JB_SPACE_CLIENT_SECRET
                crane auth login ${'$'}GEOCAT_DOCKER_REGISTRY_URL -u ${'$'}GEOCAT_DOCKER_REGISTRY_USER -p ${'$'}GEOCAT_DOCKER_REGISTRY_PASSWORD
				crane copy geocat.registry.jetbrains.space/p/jrc-inspire-portal/docker/activemq:${'$'}BRANCH-${'$'}JB_SPACE_EXECUTION_NUMBER ${'$'}GEOCAT_DOCKER_REGISTRY_URL/jrc-inspire-portal/activemq:${'$'}BRANCH-${'$'}JB_SPACE_EXECUTION_NUMBER
				crane copy geocat.registry.jetbrains.space/p/jrc-inspire-portal/docker/activemq:${'$'}BRANCH-${'$'}JB_SPACE_EXECUTION_NUMBER ${'$'}GEOCAT_DOCKER_REGISTRY_URL/jrc-inspire-portal/activemq:${'$'}BRANCH
			"""
        }
    }

}
