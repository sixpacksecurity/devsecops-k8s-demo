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

  stages {
      stage('SonarQube - SAST') {
            steps {
              sh "mvn clean verify sonar:sonar -Dsonar.projectKey=sample-app -Dsonar.host.url=http://18.142.138.97:9000 -Dsonar.login=sqp_efe5f49e134ccb0cbc3ffe0a48aed2ece1174c47"
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
