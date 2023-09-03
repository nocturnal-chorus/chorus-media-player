pipeline {
  // pipeline 的触发方式
  triggers {
    GenericTrigger(
      genericVariables: [
        [
          key: 'name',
          value: '$.repository.name',
          expressionType: 'JSONPath',
          regularFilter: '',
          defaultValue: ''
        ]
      ],
      printContributedVariables: false,
      printPostContent: false,
      regexpFilterText: '$name',
      regexpFilterExpression: '^chorus',
      causeString: ' Triggered on $ref' ,
    )
  }

  // 代理
  agent {
    docker {
      image 'registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/chorus-media-player-build:latest'
      args '-v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro'
    }
  }
  // 阶段
  stages {
    stage('pull code') {
      environment {
        url = 'https://github.com/nocturnal-chorus/chorus-media-player'
      }
      steps {
        retry(3) {
          git(url: env.url, branch: 'develop')
        }
      }
    }
    stage('install and build') {
      steps {
        retry(2) {
          sh 'cd player && flutter build web --release'
        }
      }
    }
    stage('compress') {
      steps {
        // 压缩构建后的文件用于发布到服务器的 nginx 中
        retry(2) {
          sh '''
          cd /var/jenkins_home/workspace/chorus-media-player/player/build/web
          tar -zcf chorus-media-player.tar.gz *
          '''
        }
      }
    }
    stage('ssh') {
      // https://plugins.jenkins.io/ssh-steps/
      steps {
        script {
          def remote = [:]
          remote.name = 'root'
          remote.logLevel = 'WARNING'
          remote.host = 'www.nocturnal-chorus.com'
          remote.allowAnyHosts = true
          withCredentials([usernamePassword(credentialsId: 'vps-admin', passwordVariable: 'password', usernameVariable: 'username')]) {
            remote.user = "${username}"
            remote.password = "${password}"
          }
          sshCommand remote: remote, command: '''#!/bin/bash
            cd /www/wwwroot/www.nocturnal-chorus.com/
            shopt -s extglob
            rm -rf !(.htaccess|.user.ini|.well-known|favicon.ico|chorus-media-player.tar.gz)
            '''
          sshPut remote: remote, from: '/var/jenkins_home/workspace/chorus-media-player/player/build/web/chorus-media-player.tar.gz', into: '/www/wwwroot/www.nocturnal-chorus.com/'
          sshCommand remote: remote, command: "cd /www/wwwroot/www.nocturnal-chorus.com/ && tar -xf chorus-media-player.tar.gz"
          sshRemove remote: remote, path: '/www/wwwroot/www.nocturnal-chorus.com/chorus-media-player.tar.gz'
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
      sh 'curl --globoff "https://bark.alomerry.com/$barkDevice/Blog%20build%20status%3A%20%5B%20Failed%20%5D?icon=https%3A%2F%2F${cdnDomain}%2Fmedia%2Fimages%2Fjenkins.png&url=https%3A%2F%2Fci.alomerry.com%2Fjob%2Fchrous-media-player-build%2F${BUILD_NUMBER}%2Fconsole&isArchive=0&group=jenkins&sound=electronic"'
    }
  }
}
