pipeline {
    agent {label 'nop'}
    stages{
        stage(git) {
            steps {
              git url: 'https://github.com/nopSolutions/nopCommerce.git',
                branch:'develop'
            }
        }
        stage(build) {
            steps {
              cleanWs()
              sh 'mkdir published'
              sh 'dotnet publish -c Release src/Presentation/Nop.Web/Nop.Web.csproj -o ./published'
              archiveArtifacts artifacts: '**/published/*'
              junit testResults: '**/surefire-reports/*.xml'
              
            }
        }
       
        
    }
}