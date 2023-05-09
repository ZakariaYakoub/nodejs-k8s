# Deploy nodejs app to k8s cluster
This project provisions a Linode Kubernetes Engine (LKE) cluster using Terraform, installs ingress-nginx in the cluster, retrieves the nodebalancer hostname, and deploys a sample Node.js application with an ingress rule.

## Pipeline Stages
### Provision LKE cluster
This stage provisions the LKE cluster using Terraform and saves the kubeconfig file to lke.yaml.

### Install ingress in the cluster
This stage installs ingress-nginx in the LKE cluster using Helm. If ingress-nginx is already installed, it skips this stage.

### Retrieve the nodebalancer hostname
This stage retrieves the hostname of the nodebalancer created by the LKE cluster and saves it to the HOSTNAME environment variable.

### Deploy application
This stage deploys a sample Node.js application to the LKE cluster using deploy-nodejs.yaml. It also creates an ingress rule for the application using ingress-app.yaml and substitutes the HOSTNAME environment variable in the file.

## Files
Jenkinsfile: Pipeline script for Jenkins <br>
terraform: Folder containing Terraform configuration to provision the LKE cluster <br>
deploy-nodejs.yaml: Kubernetes configuration file to deploy the sample Node.js application <br>
ingress-app.yaml: Kubernetes configuration file to create an ingress rule for the sample application <br>
