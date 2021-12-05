terraform {
  required_providers {
    azurerm = {
      version = "=2.83.0"
    }
    azuread = {
      version = "=2.8.0"
    }
    tls = {
      version = "~> 2.1" 
    }
    http = {
      version = "~> 2.1" 
    }
    helm = {}
    kubernetes = {}
  }
  backend "azurerm" {
  }
}

# data "terraform_remote_state" "state" {
#  backend = "azurerm"
#  config {
#    resource_group_name  = "${var.resource_group_name}"
#    storage_account_name = "${var.storage_account_name}"
#    container_name       = "${var.storage_container_name}"
#    key                  = "${var.blob_container_name}"
#  }
#}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
  token                  = data.azurerm_kubernetes_cluster.credentials.kube_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
  }
}
