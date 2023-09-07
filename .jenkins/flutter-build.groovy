pipeline {
  triggers {
    GenericTrigger(
      genericVariables: [
        [ key: 'name', value: '$.repository.name', expressionType: 'JSONPath' ],
        [ key: 'branch', value: '$.ref', expressionType: 'JSONPath' ],
        [ key: 'changed_files', value: '$.commits[*].["modified","added","removed"][*]', expressionType: 'JSONPath' ],
      ],
      printContributedVariables: false,
      printPostContent: false,
      tokenCredentialId: 'webhook-trigger-token',
      regexpFilterText: '$name@$branch@$changed_files',
      regexpFilterExpression: 'chorus-media-player@refs/heads/develop@.*\\"player/.*',
      causeString: ' Triggered on $branch' ,
    )
  }

  agent {
    docker {
      image 'registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/chorus-media-player-build:latest'
      args '-v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro'
    }
  }
  stages {
    stage('pull code') {
      environment {
        url = 'https://gitee.com/nocturnal-chorus/chorus-media-player.git'
      }
      steps {
        retry(3) {
          git(url: env.url, branch: 'develop')
        }
      }
    }
    stage('build') {
      steps {
        sh 'cd player && flutter clean && flutter build web --no-tree-shake-icons --release'
      }
    }
    stage('compress') {
      steps {
        sh '''
        cd /var/jenkins_home/workspace/chorus-media-player-build/player/build/web/
        tar -zcf chorus-media-player.tar.gz *
        '''
      }
    }
    stage('ssh') {
      // https://plugins.jenkins.io/ssh-steps/
      steps {
        script {
          def remote = [:]
          remote.name = 'root'
          remote.logLevel = 'WARNING'
          remote.host = 'player.nocturnal-chorus.com'
          remote.allowAnyHosts = true
          withCredentials([usernamePassword(credentialsId: 'vps-admin', passwordVariable: 'password', usernameVariable: 'username')]) {
            remote.user = "${username}"
            remote.password = "${password}"
          }
          sshCommand remote: remote, command: '''#!/bin/bash
            cd /www/wwwroot/player.nocturnal-chorus.com/
            shopt -s extglob
            rm -rf !(.htaccess|.user.ini|.well-known|favicon.ico|chorus-media-player.tar.gz)
            '''
          sshPut remote: remote, from: '/var/jenkins_home/workspace/chorus-media-player-build/player/build/web/chorus-media-player.tar.gz', into: '/www/wwwroot/player.nocturnal-chorus.com/'
          sshCommand remote: remote, command: "cd /www/wwwroot/player.nocturnal-chorus.com/ && tar -xf chorus-media-player.tar.gz"
          sshRemove remote: remote, path: '/www/wwwroot/player.nocturnal-chorus.com/chorus-media-player.tar.gz'
        }
      }
    }
  }

  environment {
    barkDevice = credentials('bark-notification-device-tobery1')
    cdnDomain = credentials('cdn-domain')
    BUILD_NUMBER = "${env.BUILD_NUMBER}"
  }
  post {
    success {
      sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Blog%20build%20status%3A%20%5B%20Success%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&isArchive=0&group=jenkins&sound=electronic&level=passive"'
    }
    failure {
      sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Blog%20build%20status%3A%20%5B%20Failed%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&url=https%3A%2F%2Fci.alomerry.com%2Fjob%2Fchorus-media-player-build%2F${BUILD_NUMBER}%2Fconsole&isArchive=0&group=jenkins&sound=electronic"'
    }
  }
}
