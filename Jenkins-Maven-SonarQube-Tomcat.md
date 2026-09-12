// Required Jenkins tools/plugins:
// 1. Maven
// maven is the username
// 2. SonarQube Scanner for Jenkins
//sonarqube is the username
// 3. Deploy to Container plugin
//add deploy to container plugin and iniate tomcat credentilas
// Pipeline flow:
// GitHub → Maven Build → SonarQube Analysis → Tomcat Deployment



pipeline {
    agent any
    tools {
        maven "maven"
    }
    stages {
        stage ("Code") {
            steps {
                git 'https://github.com/shaikmustafa77/one.git'
            }
        }
        stage ("Build") {
             steps {
                 sh "mvn clean package"
            }
        }
        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar"
                }
            }
        }
        stage("Deploy") {
            steps {
                deploy adapters: [
                    tomcat9(
                        alternativeDeploymentContext: '',
                        credentialsId: 'tomcat',
                        path: '',
                        url: 'http://107.23.153.181:8080'
                    )
                ],
                contextPath: 'website',
                war: 'target/*.war'
            }
        }
    }
}
