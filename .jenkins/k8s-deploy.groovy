pipeline {
  agent any
  parameters {
    string(name: 'PROJECT', defaultValue: '', description: 'Which project need to deploy [backend, openapi]')
    string(name: 'MODULES', defaultValue: '', description: 'Which module need to deploy')
    string(name: 'VERSION', defaultValue: 'latest', description: 'Which version need to deploy')
  }
  stages {
    stage('deploy service') {
      // environment {
      //   K8S_MASTER = credentials('k8s-master')
      // }
      steps {
        script {
          if (params.PROJECT != "" && params.MODULES != "") {
            def remote = [:]
            remote.name = 'root'
            remote.logLevel = 'WARNING'
            remote.host = 'host.docker.internal'
            remote.allowAnyHosts = true
            withCredentials([usernamePassword(credentialsId: 'k8s-master', passwordVariable: 'password', usernameVariable: 'username')]) {
              remote.user = "${username}"
              remote.password = "${password}"
            }

            def (deployment, appName, imageId, registry) = ["", "", "", "registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus"];
            def services = params.MODULES.split(' ');
            if (services.size() > 0) {
              services.each{
                switch(params.PROJECT) {
                  case "backend":
                    deployment = "player-${it}-deployment"
                    appName = "player-${it}"
                    imageId = "player-backend-${it}"
                    break
                  case "openapi":
                    deployment = "player-openapi-${it}-deployment"
                    appName = "player-openapi-${it}"
                    imageId = "player-openapi-${it}"
                    break
                }
                sshCommand remote: remote, command: """
                  export KUBECONFIG=/etc/kubernetes/admin.conf
                  kubectl set image -n nocturnal-chorus-player deployment/${deployment} ${appName}=${registry}/${imageId}:${VERSION}
                """
              }
            }
          }
        }
      }
    }
  }
}
