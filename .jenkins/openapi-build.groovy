pipeline {
  agent none
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
    stage('build openapi') {
      agent {
        docker {
          image 'registry.cn-hangzhou.aliyuncs.com/alomerry/base-golang:1.21'
        }
      }
      steps {
        sh "cd backend && ./build.sh openapi-consumer"
        // sh "cd backend && ./build.sh openapi-business"
      }
    }
    stage('build consumer docker') {
      agent any
      environment {
        DOCKER_ACESS = credentials('docker-login')
      }
      steps {
        script {
          // TODO business
          def version = System.currentTimeMillis();
          sh """
          cd backend
          docker build -t registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-openapi-consumer:v$version --build-arg module=$it -f openapi/consumer/docker/Dockerfile .
          """
          sh 'echo ${DOCKER_ACESS_PSW} | docker login --username=${DOCKER_ACESS_USR} registry.cn-hangzhou.aliyuncs.com --password-stdin'
          sh "docker push registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-openapi-consumer:v$version"
          sh 'echo "y" | docker image prune'
          build job: 'chorus-media-player-k8s-deploy', parameters: [
            [$class: 'StringParameterValue', name: 'PROJECT', value: "openapi"],
            [$class: 'StringParameterValue', name: 'MODULES', value: "consumer"],
            [$class: 'StringParameterValue', name: 'VERSION', value: "v"+version]
          ], wait: false
        }
      }
    }
    // TODO deploy to k8s
  }
}
