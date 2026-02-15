pipeline {
    agent any

    environment {
        // AWS Credentials from Jenkins Credentials Manager
        AWS_CREDENTIALS_ID = 'aws-creds'
        AWS_REGION = 'us-east-1'
        
        // Project Details
        CLUSTER_NAME = 'ecommerce-cluster'
        TERRAFORM_DIR = '.' 
    }

    parameters {
        choice(name: 'TF_ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Select Terraform Action')
    }

    stages {
        stage('Checkout Source') {
            steps {
                git branch: 'main', url: 'https://github.com/rknikhade1419/E-commerce-EKS-Cluster-Deployment.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Action') {
            steps {
                withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        if (params.TF_ACTION == 'plan') {
                            sh 'terraform plan'
                        } else if (params.TF_ACTION == 'apply') {
                            sh 'terraform apply -auto-approve'
                        } else if (params.TF_ACTION == 'destroy') {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Update Kubeconfig') {
            // Only runs if we successfully applied the infrastructure
            when { expression { params.TF_ACTION == 'apply' } }
            steps {
                withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
                    sh "kubectl get nodes"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Successfully executed ${params.TF_ACTION} for ${CLUSTER_NAME}"
        }
    }
}