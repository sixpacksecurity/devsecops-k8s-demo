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
        }
    
      stage('SonarQube - SAST') {
            steps {
              withSonarQubeEnv('SonarQube') {
              sh "mvn clean verify sonar:sonar -Dsonar.projectKey=sample-app -Dsonar.host.url=http://18.140.114.228:9000"
            }
//              timeout(time: 2, unit: 'MINUTES') {
//          script {
//            waitForQualityGate abortPipeline: true
//          }
//              }
            }
        }
    
      stage('Vulnerability Scan - Docker') {
      steps {
        parallel(
          "Dependency Scan": {
            sh "mvn dependency-check:check"
          },
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          }
        )
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
  
    post {
            always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            }
          }
}
