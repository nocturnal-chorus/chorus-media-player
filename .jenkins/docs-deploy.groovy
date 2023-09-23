// chorus-media-player-docs-deploy
pipeline {
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
      regexpFilterExpression: 'chorus-media-player@refs/heads/develop@.*\\"docs/.*',
      causeString: ' Triggered on $branch' ,
    )
  }
  agent {
    kubernetes {
      yaml """
      apiVersion: v1
      kind: Pod
      metadata:
        namespace: alomerry
        labels:
          service: jenkins-builder-chorus-media-player-docs-deploy
      spec:
        containers:
        - name: chorus-media-player-docs-build
          image: registry.cn-hangzhou.aliyuncs.com/alomerry/base-frontend:v20.5.1
          imagePullPolicy: Always
      """
      retries 2
    }
  }
  stages {
    stage('init') {
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
    stage('build') {
      steps {
        container('chorus-media-player-docs-build') {
          sh '''
          cd docs && pnpm install && pnpm build
          cd .vitepress/dist
          tar -zcf chorus-media-player-docs.tar.gz *
          '''
        }
      }
    }
    stage('ssh') {
      steps {
        script {
          def remote = [:]
          remote.name = 'root'
          remote.logLevel = 'WARNING'
          remote.host = 'player-docs.nocturnal-chorus.com'
          remote.allowAnyHosts = true
          withCredentials([usernamePassword(credentialsId: 'vps-admin', passwordVariable: 'password', usernameVariable: 'username')]) {
            remote.user = "${username}"
            remote.password = "${password}"
          }
          sshCommand remote: remote, command: '''#!/bin/bash
            cd /www/wwwroot/player-docs.nocturnal-chorus.com/
            shopt -s extglob
            rm -rf !(.htaccess|.user.ini|.well-known|favicon.ico|chorus-media-player-docs.tar.gz)
            '''
          sshPut remote: remote, from: 'docs/.vitepress/dist/chorus-media-player-docs.tar.gz', into: '/www/wwwroot/player-docs.nocturnal-chorus.com/'
          sshCommand remote: remote, command: "cd /www/wwwroot/player-docs.nocturnal-chorus.com/ && tar -xf chorus-media-player-docs.tar.gz"
          sshRemove remote: remote, path: '/www/wwwroot/player-docs.nocturnal-chorus.com/chorus-media-player-docs.tar.gz'
        }
      }
    }
  }

  // environment {
  //   barkDevice = credentials('bark-notification-device-alomerry')
  //   cdnDomain = credentials('cdn-domain')
  //   BUILD_NUMBER = "${env.BUILD_NUMBER}"
  // }
  // post {
  //   success {
  //     sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Player-docs%20build%20status%3A%20%5B%20Success%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&isArchive=0&group=jenkins&sound=electronic&level=passive"'
  //   }
  //   failure {
  //     sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Player-docs%20build%20status%3A%20%5B%20Failed%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&url=https%3A%2F%2Fci.alomerry.com%2Fjob%2Fchorus-media-player-docs-deploy%2F${BUILD_NUMBER}%2Fconsole&isArchive=0&group=jenkins&sound=electronic"'
  //   }
  // }
}
