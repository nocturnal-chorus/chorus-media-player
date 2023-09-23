// chorus-media-player-client-build
pipeline {
  parameters {
    choice(name: 'PLATFORM', choices: ['web'], description: 'Which service need to build')
  }
  options {
    disableResume()
    disableConcurrentBuilds(abortPrevious: true)
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
    kubernetes {
      yaml '''
      apiVersion: v1
      kind: Pod
      metadata:
        namespace: alomerry
        labels:
          service: jenkins-builder-chorus-media-player-client
      spec:
        containers:
        - name: builder
          image: registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/chorus-media-player-build:latest
      '''
    }
  }
  stages {
    stage('pull code') {
      steps {
        sh"""
        ([ -e .git ] && (git pull https://gitee.com/nocturnal-chorus/chorus-media-player.git develop)) || git clone -b develop https://gitee.com/nocturnal-chorus/chorus-media-player.git .
        """
        wrap([$class: 'BuildUser']) {
          script {
            def BUILD_REASON = sh(returnStdout: true, script: 'git show -s | grep -vE "commit|Date" | grep -v "^$"  | grep -v "Merge pull"')
            def BUILD_TRIGGER_BY = 'admin'
            if (env.BUILD_USER) {
              BUILD_TRIGGER_BY = env.BUILD_USER
            }
            buildName "develop#${BUILD_NUMBER} / ${BUILD_TRIGGER_BY}"
            buildDescription "${BUILD_REASON}"
          }
        }
      }
    }
    stage('build:web') {
      when {
        expression {
          params.PLATFORM == 'web'
        }
      }
      steps {
        script {
          container('builder') {
            sh 'cd player && flutter clean && flutter build web --no-tree-shake-icons --release'
            sh '''
            cd player/build/web/
            tar -zcf chorus-media-player.tar.gz *
            '''
          }
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
          sshPut remote: remote, from: 'player/build/web/chorus-media-player.tar.gz', into: '/www/wwwroot/player.nocturnal-chorus.com/'
          sshCommand remote: remote, command: "cd /www/wwwroot/player.nocturnal-chorus.com/ && tar -xf chorus-media-player.tar.gz"
          sshRemove remote: remote, path: '/www/wwwroot/player.nocturnal-chorus.com/chorus-media-player.tar.gz'
        }
      }
    }
  }

  // environment {
  //   barkDevice = credentials('bark-notification-device-tobery1')
  //   cdnDomain = credentials('cdn-domain')
  //   BUILD_NUMBER = "${env.BUILD_NUMBER}"
  // }
  // post {
  //   success {
  //     sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Player%20build%20status%3A%20%5B%20Success%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&isArchive=0&group=jenkins&sound=electronic&level=passive"'
  //   }
  //   failure {
  //     sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Player%20build%20status%3A%20%5B%20Failed%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&url=https%3A%2F%2Fci.alomerry.com%2Fjob%2Fchorus-media-player-build%2F${BUILD_NUMBER}%2Fconsole&isArchive=0&group=jenkins&sound=electronic"'
  //   }
  // }
}
