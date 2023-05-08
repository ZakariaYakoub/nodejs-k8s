terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
    }
  }
}

provider "linode" {
}

resource "linode_lke_cluster" "my-cluster" {
    label       = "my-cluster"
    k8s_version = "1.25"
    region      = "eu-central"
    tags        = ["prod"]

    pool {
        type  = "g6-standard-1"
        count = 2
    }
}

output "kubeconfig" {
   value = linode_lke_cluster.my-cluster.kubeconfig
   sensitive = true
}
