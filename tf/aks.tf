resource "random_pet" "this" {
}

resource "tls_private_key" "cardano" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_network" "cardano" {
  name                = format("%s-vnet", var.cluster_name == "" ? random_pet.this.id : var.cluster_name)
  location            = azurerm_resource_group.cardano.location
  resource_group_name = azurerm_resource_group.cardano.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = azurerm_virtual_network.cardano.name
  resource_group_name  = azurerm_resource_group.cardano.name
  address_prefixes     = ["10.1.0.0/22"]
}
resource "azurerm_subnet" "user" {
  name                 = "user"
  virtual_network_name = azurerm_virtual_network.cardano.name
  resource_group_name  = azurerm_resource_group.cardano.name
  address_prefixes     = ["10.1.4.0/22"]
  service_endpoints    = [ "Microsoft.KeyVault" ]
}

resource "azurerm_kubernetes_cluster" "cardano" {
  name                      = var.cluster_name == "" ? random_pet.this.id : var.cluster_name
  location                  = azurerm_resource_group.cardano.location
  resource_group_name       = azurerm_resource_group.cardano.name
  dns_prefix                = format("%s-dns", var.dns_prefix == "" ? random_pet.this.id : var.dns_prefix)
  kubernetes_version        = "1.21.2"
  private_cluster_enabled   = false
  sku_tier                  = "Paid"

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.internal.id
    only_critical_addons_enabled = true  # ["CriticalAddonsOnly=true:NoSchedule"]
    node_labels           = {
        Tier        = "internal"
        Type        = "OnDemand"
    }
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

#  role_based_access_control {
#    enabled = true
#
#    azure_active_directory {
#      managed = true
#      admin_group_object_ids = [
#        data.azuread_group.cardano.id
#      ]
#    }
#  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = replace(var.public_ssh_key == "" ? tls_private_key.cardano.public_key_openssh : var.public_ssh_key, "\n", "")
    }
  }

  dynamic addon_profile {
    for_each = var.enable_log_analytics_workspace ? ["log_analytics"] : []
    content {
      oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id
      }
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups       = true
    max_graceful_termination_sec      = 300
    scale_down_delay_after_add        = "10m"
    scale_down_delay_after_delete     = "10s"
    scan_interval                     = "10s"
    scale_down_delay_after_failure    = "3m"
    scale_down_unneeded               = "10m"
    scale_down_unready                = "20m"
    scale_down_utilization_threshold  = 0.5
  }

  timeouts {
    create = "2h"
    delete = "2h"
    update = "2h"
    read   = "5m"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cardano.id
  vm_size               = "Standard_E4s_v4"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.user.id
}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.cardano.name
  resource_group_name = azurerm_resource_group.cardano.name
}
