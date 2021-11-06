output "cluster_name" {
  value = random_pet.this
}

output "fqdn" {
  value = azurerm_kubernetes_cluster.cardano.fqdn
}

output "name" {
  value = azurerm_kubernetes_cluster.cardano.name
}

output "id" {
  value = azurerm_kubernetes_cluster.cardano.id
}

output "kubelet_client_id" {
  value = azurerm_kubernetes_cluster.cardano.kubelet_identity[0].client_id
}

output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.cardano.kubelet_identity[0].object_id
}

output "kubelet_user_assigned_identity_id" {
  value = azurerm_kubernetes_cluster.cardano.kubelet_identity[0].user_assigned_identity_id
}

