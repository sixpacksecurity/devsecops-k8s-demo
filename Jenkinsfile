pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //test
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
      stage('Docker Build and Push') {
        steps {
//          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh 'docker build -t sixpacksec/numeric-app:""$GIT_COMMIT"" .'
//            sh 'docker push sixpacksec/numeric-app:""$GIT_COMMIT""'
          }
        }
      }
    }
}
