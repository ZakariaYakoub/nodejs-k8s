pipeline {
    agent any
    environment {
        LINODE_TOKEN = credentials('linode_token')
    }

    stages {
        stage('Provision Linode cluster (LKE)') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh "terraform apply --auto-approve"
                    sh "terraform output kubeconfig | jq -r '@base64d' > ../mycluster.yaml"
                    sh "chmod 600 ../mycluster.yaml"
                }
            }
        }

        stage("install ingress in the cluster") {
            environment {
                KUBECONFIG = "--kubeconfig='mycluster.yaml'"
            }
            steps {
                script {
                    def chartlist = sh(script: "helm list -n default -f ingress-nginx -q $KUBECONFIG", returnStdout: true).trim()
                    if (chartlist) {
                        echo "The Ingress-nginx chart is already installed."
                    } else {
                        sh "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
                        sh "helm repo update"
                        sh "helm install ingress-nginx ingress-nginx/ingress-nginx $KUBECONFIG"
                        sh "sleep 15"
                    }
                }
            }
        }

        stage("retrieve the nodebalancer hostname") {
            environment {
                KUBECONFIG = "--kubeconfig='mycluster.yaml'"
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
                KUBECONFIG = "--kubeconfig='mycluster.yaml'"
            }
            steps {
                script {
                    
                    sh "kubectl apply -f deploy-nodejs.yaml $KUBECONFIG"
                    sh "envsubst  < ingress-app.yaml | kubectl apply -f - $KUBECONFIG"
                }
            }
        }
    }
}