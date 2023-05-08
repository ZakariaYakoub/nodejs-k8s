pipeline {
    agent any
    environment {
        LINODE_TOKEN = credentials('api_token')
    }

    stages {
        stage('Provision LKE cluster') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh "terraform apply --auto-approve"
                    sh "terraform output kubeconfig | jq -r '@base64d' > ../lke.yaml"
                }
            }
        }

        stage("install ingress in the cluster") {
            environment {
                KUBECONFIG = "--kubeconfig='lke.yaml'"
            }
            steps {
                script {
                        sh "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
                        sh "helm repo update"
                        sh "helm install ingress-nginx ingress-nginx/ingress-nginx $KUBECONFIG"
                        sh "sleep 15"
                }
            }
        }

        stage("retrieve the nodebalancer hostname") {
            environment {
                KUBECONFIG = "--kubeconfig='lke.yaml'"
            }
            steps {
                script {
                    def nodebalancer = sh(script: "curl -s -H \"Authorization: Bearer ${env.LINODE_TOKEN}\" https://api.linode.com/v4/nodebalancers | jq -r '.data[0].hostname'", returnStdout: true).trim()
                    echo "NodeBalancer hostname: ${nodebalancer}"
                    env.HOSTNAME = nodebalancer
                }
            }
        }

        stage('Deploy application') {
            environment {
                KUBECONFIG = "--kubeconfig='lke.yaml'"
            }
            steps {
                script {
                    
                    sh "kubectl apply -f deploy-nodejs.yaml $KUBECONFIG"
                    sh "evesubt < ingress-app.yaml | kubectl apply -f "
                }
            }
        }
    }
}