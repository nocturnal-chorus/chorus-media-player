pipeline {
  agent none
  parameters {
    choice(name: 'SERVICE', choices: ['all', 'music', 'member'], description: 'Which service need to build')
  }
  triggers {
    GenericTrigger(
      genericVariables: [
        [ key: 'name', value: '$.repository.name', expressionType: 'JSONPath' ],
        [ key: 'branch', value: '$.ref', expressionType: 'JSONPath' ],
        [ key: 'COMMIT_BEFORE_SHA', value: '$.commits[0].parent_ids[0]', expressionType: 'JSONPath' ],
        [ key: 'COMMIT_AFTER_SHA', value: '$.after', expressionType: 'JSONPath' ],
        [ key: 'changed_files', value: '$.commits[*].["modified","added","removed"][*]', expressionType: 'JSONPath' ],
      ],
      printContributedVariables: false,
      printPostContent: false,
      tokenCredentialId: 'webhook-trigger-token',
      regexpFilterText: '$name@$branch@$changed_files',
      regexpFilterExpression: 'chorus-media-player@refs/heads/develop@.*\\"backend/.*',
      causeString: ' Triggered on $branch' ,
    )
  }
  environment {
      Modules = "${SERVICE}"
  }
  stages {
    stage('pull code') {
      agent any
      environment {
        url = 'https://gitee.com/nocturnal-chorus/chorus-media-player.git'
      }
      steps {
        retry(3) {
          git(url: env.url, branch: 'develop')
        }
      }
    }
    // TODO cache
    stage('build proto') {
      agent {
        docker {
          image 'registry.cn-hangzhou.aliyuncs.com/alomerry/tool-protoc:v1'
        }
      }
      steps {
        sh '''
        cd backend
        ./build.sh proto
        '''
      }
    }
    stage('valid changed') {
      agent any
      steps {
        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
          script {
            def modules = sh(returnStdout: true, script: """
              if [ ${COMMIT_BEFORE_SHA} != '' ]; then
                echo \$(./backend/service/scripts/core/tools.sh \$(git diff --name-only ${COMMIT_BEFORE_SHA} ${COMMIT_AFTER_SHA}))
              fi
            """).trim()
            Modules = modules
          }
        }
      }
    }
    stage('build service') {
      agent {
        docker {
          image 'registry.cn-hangzhou.aliyuncs.com/alomerry/base-golang:1.21'
        }
      }
      steps {
        sh "cd backend && ./build.sh service bin ${Modules}"
      }
    }
    stage('build docker') {
      agent any
      environment {
        DOCKER_ACESS = credentials('docker-login')
      }
      steps {
        script {
          if (Modules == "all" || Modules == "") {
            Modules = "music"
          }
          def services = Modules.split(' ');
          def version = System.currentTimeMillis();
          services.each{
            sh """
            cd backend
            docker build -t registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-backend-$it:v$version --build-arg module=$it -f service/docker/Dockerfile .
            """
            sh 'echo ${DOCKER_ACESS_PSW} | docker login --username=${DOCKER_ACESS_USR} registry.cn-hangzhou.aliyuncs.com --password-stdin'
            sh "docker push registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-backend-$it:v$version"
          }
        }
      }
    }
    // TODO deploy to k8s
  }
}
