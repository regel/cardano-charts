data "azuread_group" "cardano" {
  display_name = var.aad_group_name
}

data "azurerm_subscription" "primary" {
}

#resource "azurerm_role_definition" "velero-operator" {
#  name        = "Velero Snapshot Operator"
#  scope       = data.azurerm_subscription.primary.id
#  description = "Can snapshot PV in AKS clusters."
#  permissions {
#    actions     = [
#        "Microsoft.Compute/disks/read",
#        "Microsoft.Compute/disks/write",
#        "Microsoft.Compute/disks/endGetAccess/action",
#        "Microsoft.Compute/disks/beginGetAccess/action",
#        "Microsoft.Compute/snapshots/read",
#        "Microsoft.Compute/snapshots/write",
#        "Microsoft.Compute/snapshots/delete",
#        "Microsoft.Compute/disks/beginGetAccess/action",
#        "Microsoft.Compute/disks/endGetAccess/action",
#        "Microsoft.Storage/storageAccounts/listKeys/action"
#    ]
#    not_actions = []
#  }
#
#  assignable_scopes = [
#    data.azurerm_subscription.primary.id, # /subscriptions/00000000-0000-0000-0000-000000000000
#  ]
#}
