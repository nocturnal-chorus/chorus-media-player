// chorus-media-player-backend-build
def Modules = ""
def InitBuildService() {
  def modules = sh(returnStdout: true, script: """
    if [ ${COMMIT_BEFORE_SHA} != '' ]; then
      echo \$(./backend/service/scripts/core/tools.sh \$(git diff --name-only ${COMMIT_BEFORE_SHA} ${COMMIT_AFTER_SHA}))
    fi
  """).trim()
  Modules = modules
}
pipeline {
  parameters {
    choice(name: 'SERVICE', choices: ['all', 'music', 'member'], description: 'Which service need to build')
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
        [ key: 'COMMIT_BEFORE_SHA', value: '$.commits[0].parent_ids[0]', expressionType: 'JSONPath' ],
        [ key: 'COMMIT_AFTER_SHA', value: '$.after', expressionType: 'JSONPath' ],
        [ key: 'changed_files', value: '$.commits[*].["modified","added","removed"][*]', expressionType: 'JSONPath' ],
      ],
      printContributedVariables: false,
      printPostContent: false,
      tokenCredentialId: 'webhook-trigger-token',
      regexpFilterText: '$name@$branch@$changed_files',
      regexpFilterExpression: 'chorus-media-player@refs/heads/develop@.*\\"backend/(proto|service).*',
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
          service: jenkins-builder-chorus-media-player-backend-service-build
      spec:
        containers:
        - name: dind
          image: docker:24.0.6-dind
          tty: true
          securityContext:
            privileged: true
          command:
            - dockerd
            - --host=tcp://0.0.0.0:8000
            - --host=unix:///var/run/docker.sock
            - --tls=false
          volumeMounts:
            - mountPath: /var/run
              name: docker-sock
          readinessProbe:
            exec:
              command: ["docker", "info"]
            initialDelaySeconds: 10
            failureThreshold: 6
        - name: docker-builder
          image: docker:24.0.6
          tty: true
          securityContext:
            privileged: true
          volumeMounts:
            - mountPath: /var/run
              name: docker-sock
        - name: tool-protoc
          image: registry.cn-hangzhou.aliyuncs.com/alomerry/tool-protoc:v1
          imagePullPolicy: Always
        - name: base-golang
          image: registry.cn-hangzhou.aliyuncs.com/alomerry/base-golang:1.21
          imagePullPolicy: Always
        volumes:
          - name: docker-sock
            emptyDir: {}
      """
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
    stage('valid changed') {
      steps {
        script {
          try {
            InitBuildService()
          } catch (Exception e) {
            // empty
          }
          if (params.SERVICE == "all" || Modules == "") {
            Modules = "music"
          }
        }
      }
    }
    // TODO cache
    stage('build proto') {
      steps {
        container('tool-protoc') {
          sh '''
          cd backend
          ./build.sh proto
          '''
        }
      }
    }
    stage('build service') {
      steps {
        container('base-golang') {
          sh "cd backend && ./build.sh service bin ${Modules}"
        }
      }
    }
    stage('build docker') {
      environment {
        DOCKER_ACESS = credentials('docker-login')
        VERSION = System.currentTimeMillis()
      }
      steps {
        script {
          sh(returnStdout: false, script: 'echo $DOCKER_ACESS_PSW > dockerCredentials')
        }
        container('docker-builder') {
          sh 'docker -v'
          sh "cat dockerCredentials | docker login --username=docker.chorus@alomerry registry.cn-hangzhou.aliyuncs.com --password-stdin"
          sh """
          cd backend
          services=${Modules}
          IFS=" "; \
          set -- \$services; \
          echo "\$@"
          for it in "\$@"; do \
            docker build -t registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-backend-\$it:v${env.VERSION} -t registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-backend-\$it:latest --build-arg module=\$it -f service/docker/Dockerfile .; \
            docker push registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-backend-\$it:v${env.VERSION}; \
            docker push registry.cn-hangzhou.aliyuncs.com/nocturnal-chorus/player-backend-\$it:latest; \
          done
          echo "y" | docker image prune
          """
        }
        build job: 'chorus-media-player-k8s-deploy', parameters: [
          [$class: 'StringParameterValue', name: 'PROJECT', value: "backend"],
          [$class: 'StringParameterValue', name: 'MODULES', value: "${Modules}"],
          [$class: 'StringParameterValue', name: 'VERSION', value: "v${env.VERSION}"]
        ], wait: false
      }
    }
  }
}
