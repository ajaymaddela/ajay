pipeline {
    agent { label 'ajay' }
    
    parameters {
        choice(
            name: 'Docker_image',
            choices: ['ajaykumar020/spc:1.0', 'ajaykumar020/spc:2.0', 'ajaykumar020/spc:latest'],
            description: 'Select the Docker image name and tag.'
        )
        choice(
            name: 'TF_APPLY_FLAGS',
            choices: ['-auto-approve', ''],
            description: 'Select Terraform apply flags (e.g., -auto-approve or none).'
        )
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/ajaymaddela/spring-petclinic-2024-03.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package' 
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker image build -t ${params.Docker_image} ."
            }
        }

        stage('Terraform Init') {
            steps {
                dir('deployment/terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('deployment/terraform') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('deployment/terraform') {
                    script {
                        def tfCommand = "terraform apply ${params.TF_APPLY_FLAGS}"
                        echo "Running command: ${tfCommand}"
                        sh tfCommand
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh "kubectl apply -f deployment/k8s/spc.yaml"
                sh """
                kubectl patch deployment spc -p '{"spec":{"template":{"spec":{"containers":[{"name":"spc","image":"${params.Docker_image}"}]}}}}'
                """
            }
        }

        stage('Display ASCII Art') {
            steps {
                script {
                    echo '''
███████ ██    ██  ██████  ██████ ███████ ███████ ███████ 
██      ██    ██ ██      ██      ██      ██      ██      
███████ ██    ██ ██      ██      █████   ███████ ███████ 
     ██ ██    ██ ██      ██      ██           ██      ██ 
███████  ██████   ██████  ██████ ███████ ███████ ███████ 
                                                         
                                                         
'''
                }
            }
        }
    }
}











