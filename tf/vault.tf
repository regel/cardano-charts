resource "random_string" "vault" {
  length           = 5
  special          = false
  lower            = false
  upper            = false
  number           = true
}


data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "cardano" {
  name                        = format("%s%s", random_pet.this.id, random_string.vault.id)
  location                    = azurerm_resource_group.cardano.location
  resource_group_name         = azurerm_resource_group.cardano.name
  enabled_for_disk_encryption = true
  tenant_id                   = azurerm_kubernetes_cluster.cardano.identity[0].tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  network_acls {
    bypass = "AzureServices"  # required when enabled_for_disk_encryption == true
    default_action = "Deny"
    virtual_network_subnet_ids = [ azurerm_subnet.user.id ]
    ip_rules = compact(["${chomp(data.http.myip.body)}/32", var.allow_cidr])
  }
}

resource "azurerm_key_vault_access_policy" "cluster" {
  key_vault_id = azurerm_key_vault.cardano.id
  tenant_id = azurerm_kubernetes_cluster.cardano.identity[0].tenant_id
  object_id = azurerm_kubernetes_cluster.cardano.identity[0].principal_id

  key_permissions = [
    "Get",
  ]
  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "kubelet" {
  key_vault_id = azurerm_key_vault.cardano.id
  tenant_id = azurerm_kubernetes_cluster.cardano.identity[0].tenant_id
  object_id = azurerm_kubernetes_cluster.cardano.kubelet_identity[0].object_id

  key_permissions = [
    "Get",
  ]
  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "admins" {
  key_vault_id = azurerm_key_vault.cardano.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_group.cardano.object_id

  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}
