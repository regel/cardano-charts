data "azuread_group" "cardano" {
  display_name = var.aad_group_name
}
