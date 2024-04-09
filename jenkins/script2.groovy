pipeline {
    agent { label 'game' }
     tools {
        maven 'MAVEN_3.9.6' 
    }
    triggers {
      pollSCM('* * * * *')
    }
    stages {
        stage('git') {
            steps  {
                git url:'https://github.com/ajaymaddela/game-of-lifeapr24.git',
                  branch:'master'
                

            }
        }
        stage('build') {
            steps {
            
                sh 'mvn clean package'
            }
        }
    }
    
}
