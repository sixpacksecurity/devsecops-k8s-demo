pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //test
            }
        }
      stage('Unit Testing') {
            steps {
              sh "mvn test"
            }
        } 
    }
}
