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
    
      stage('SAST') {
        environment { 
                    // Add the rules that Semgrep uses by setting the SEMGREP_RULES environment variable. 
                    SEMGREP_RULES = "p/default"
                    // Scan changed files in PRs or MRs (diff-aware scanning):
                     SEMGREP_BASELINE_REF = "${GIT_BRANCH}"
                    // Uncomment SEMGREP_TIMEOUT to set this job's timeout (in seconds):
                    // Default timeout is 1800 seconds (30 minutes).
                    // Set to 0 to disable the timeout.
                     SEMGREP_TIMEOUT = "300"
                  }
            steps {
              parallel (
                "SonarQube": {
                  withSonarQubeEnv('SonarQube') {
                  sh "mvn clean verify sonar:sonar -Dsonar.projectKey=sample-app -Dsonar.host.url=http://18.140.114.228:9000"
                  }
                },
                "Semgrep": {
                  sh "docker run --rm -v $WORKSPACE:/src -e SEMGREP_RULES='p/default' -e SEMGREP_BASELINE_REF='${GIT_BRANCH}' -e SEMGREP_TIMEOUT='300' returntocorp/semgrep semgrep ci --config auto"
                }
  //              timeout(time: 2, unit: 'MINUTES') {
  //          script {
  //            waitForQualityGate abortPipeline: true
  //          }
  //         }
            )
           }
         }
    
      stage('Vulnerability Scan - Docker') {
      steps {
        parallel (
          "Dependency Scan": {
            sh "mvn dependency-check:check"
          },
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          },
          "Hadolint Scan": {
            sh "docker run --rm -e THRESHOLD='error' -i ghcr.io/hadolint/hadolint < Dockerfile"
          },
          "OPA Conftest": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
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
