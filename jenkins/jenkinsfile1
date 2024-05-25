pipeline {
    agent { label 'spc' }
    triggers {
        pollSCM('* * * * *')
    }
    stages {
        stage('git') {
            steps {
                git url: 'https://github.com/ajaymaddela/spring-petclinic-2024-03.git',
                  branch: 'main'
            }
        }
        stage('build') {
            steps {
                sh 'mvn clean package'
            }
        
            post {
                success {
                    archiveArtifacts '**/target/spring*.jar'
                }
            }
        }
    }
}