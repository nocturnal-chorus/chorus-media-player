pipeline {
  agent any
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
        sh 'echo $(pwd); ls'
        // sh 'docker run --rm -v ./:/app/src/ -w /app/src registry.cn-hangzhou.aliyuncs.com/alomerry/tool-protoc:v1 bash -c "./build.sh proto"'
        // sh 'docker run --rm -v ./:/app/src/ -w /app/src/service/music registry.cn-hangzhou.aliyuncs.com/alomerry/base-golang:1.21 bash -c "go build -ldflags='-s -w' -o music"'
      }
    }
  }
  
  // TODO deploy to k8s
}
