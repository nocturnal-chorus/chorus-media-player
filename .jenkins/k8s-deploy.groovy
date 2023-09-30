// chorus-media-player-k8s-deploy
pipeline {
  options {
    disableResume()
    disableConcurrentBuilds(abortPrevious: false)
    timeout(time: 15, unit: 'MINUTES')
    buildDiscarder(
      logRotator(
        numToKeepStr:'7',
        daysToKeepStr: '1',
        artifactDaysToKeepStr: '1',
        artifactNumToKeepStr: '7'
      )
    )
  }
  parameters {
    string(name: 'BRANCH', defaultValue: 'develop', description: 'Which branch need to deploy')
    choice(name: 'PROJECT', choices: ['backend', 'openapi'], description: 'Which project need to deploy [backend, openapi]')
    string(name: 'MODULES', defaultValue: '', description: 'Which module need to deploy')
    string(name: 'VERSION', defaultValue: 'latest', description: 'Which version need to deploy')
  }
  agent {
    kubernetes {
      yaml '''
      apiVersion: v1
      kind: Pod
      metadata:
        namespace: alomerry
        labels:
          service: jenkins-chorus-media-player-deploy
      spec:
        securityContext:
          runAsUser: 1000
        containers:
        - name: kubectl
          image: bitnami/kubectl:1.28.2
          tty: true
          command:
            - cat
      '''
    }
  }
  stages {
    stage('init') {
      steps {
        // if (params.BRANCH != "develop") {
        //   sh "git fetch --all && git checkout -b ${BRANCH} -f && git pull"
        // }
        sh '''
        ([ -e .git ] && (git pull https://gitee.com/nocturnal-chorus/chorus-media-player.git develop)) || git clone -b develop https://gitee.com/nocturnal-chorus/chorus-media-player.git .
        '''
        wrap([$class: 'BuildUser']) {
          script {
            def BUILD_TRIGGER_BY = 'admin'
            if (env.BUILD_USER) {
              BUILD_TRIGGER_BY = env.BUILD_USER
            }
            buildName "${params.PROJECT}#${params.BRANCH} / ${BUILD_TRIGGER_BY}"
          }
        }
      }
    }
    stage('deploy service') {
      steps {
        script {
          if (params.PROJECT != "" && params.MODULES != "") {
            switch (params.PROJECT) {
              case "backend":
                if (params.modules != "") {
                  def services = params.MODULES.split(' ');
                  if (services.size() > 0) {
                    container('kubectl') {
                      sh "kubectl apply -f .k8s/ingress.yml"
                    }
                    services.each{
                      container('kubectl') {
                        sh """
                        sed -i 's/player-backend-${it}:latest/player-backend-${it}:${params.VERSION}/' .k8s/service/${it}.yml
                        kubectl apply -f .k8s/service/${it}.yml
                        """
                      }
                    }
                  }
                }
                break
              case "openapi":
                switch (params.MODULES) {
                  case "consumer":
                    container('kubectl') {
                      sh """
                      kubectl apply -f .k8s/ingress.yml
                      sed -i 's/player-openapi-consumer:latest/player-openapi-consumer:${params.VERSION}/' .k8s/openapi/consumer.yml
                      kubectl apply -f .k8s/openapi/consumer.yml
                      """
                    }
                    break
                }
                break
            }
          }
        }
      }
    }
  }
}
