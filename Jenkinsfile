pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //test trigger
            }
        }
      stage('Unit Tests - JUnit and Jacoc') {
            steps {
              sh "mvn test"
            }
            post {
            always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
            }
          }
        }
      stage('SonarQube - SAST') {
            steps {
//              withSonarQubeEnv('SonarQube') {
              sh "mvn clean verify sonar:sonar -Dsonar.projectKey=sample-app -Dsonar.host.url=http://18.140.114.228:9000 -Dsonar.login=sqp_059a164a0dda174ea6f71a8b77942161338fd014"
//            }
//              timeout(time: 2, unit: 'MINUTES') {
//          script {
//            waitForQualityGate abortPipeline: true
//          }
//              }
            }
        }
      stage('Docker Build and Push') {
        steps {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t sixpacksec/numeric-app:""$GIT_COMMIT"" .'
            sh 'docker push sixpacksec/numeric-app:""$GIT_COMMIT""'
          }
        }
      }
      stage('Kubernetes Deployment - DEV') {
        steps {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh "sed -i 's#replace#sixpacksec/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    }
}
