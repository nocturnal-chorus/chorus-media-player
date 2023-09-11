pipeline {
  agent none
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
    stage('build proto') {
      agent {
        docker {
          image 'registry.cn-hangzhou.aliyuncs.com/alomerry/tool-protoc:v1'
        }
      }
      steps {
        sh '''
        cd /var/jenkins_home/workspace/chorus-media-player-backend-service-build/backend
        ./build.sh proto
        '''
      }
    }
    stage('build service') {
      agent {
        docker {
          image 'registry.cn-hangzhou.aliyuncs.com/alomerry/base-golang:1.21'
        }
      }
      steps {
        sh '''
        cd /var/jenkins_home/workspace/chorus-media-player-backend-service-build/backend
        ./build.sh service bin music
        '''
      }
    }
    stage('check') {
      agent any
      steps {
        sh '''
        ls -l
        pwd
        cd /var/jenkins_home/workspace/chorus-media-player-backend-service-build/backend/service/music
        ls -l
        '''
      }
    }
    // TODO deploy to k8s
  }
}
