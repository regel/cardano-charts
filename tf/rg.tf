resource "azurerm_resource_group" "cardano" {
  name     = var.resource_group_name == "" ? random_pet.this.id : var.resource_group_name 
  location = var.location
}
