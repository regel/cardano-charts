resource "random_password" "redis" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "helm_release" "csi" {
  name       = "csi-secrets-store-provider-azure"

  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  chart      = "csi-secrets-store-provider-azure"
  lint       = false
  namespace  = "kube-system"
  create_namespace = false

  set {
    name  = "secrets-store-csi-driver.syncSecret.enabled"
    value = "true"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kube-prometheus"
  lint       = false
  namespace  = "prometheus"
  create_namespace = true
}

resource "helm_release" "cardano" {
  name       = "testnet"
  repository = "https://regel.github.io/cardano-charts"
  chart      = "cardano"
  lint       = true
  namespace  = "testnet"
  create_namespace = true
  wait = false  # do not wait for readiness

  set {
    name  = "secrets.redisUsername"
    value = "cardano"
  }
  set_sensitive {
    name  = "secrets.redisPassword"
    value = random_password.redis.result
  }
  set {
    name  = "redis.auth.username"
    value = "cardano"
  }
  set_sensitive {
    name  = "redis.auth.password"
    value = random_password.redis.result
  }
  set {
    name  = "metrics.enabled"
    value = "true"
  }
  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }
  set {
    name  = "metrics.serviceMonitor.namespace"
    value = "prometheus"
  }
  set {
    name  = "vault.csi.enabled"
    value = "true"
  }
  set {
    name  = "vault.csi.coldVaultName"
    value = azurerm_key_vault.cardano.name
  }
  set {
    name  = "vault.csi.hotVaultName"
    value = azurerm_key_vault.cardano.name
  }
  set {
    name  = "vault.csi.userAssignedIdentityID"
    value = ""  # If empty, then defaults to use the SystemAssigned identity on the cluster
    type  = "string"
  }
  set {
    name  = "vault.csi.tenantId"
    value = var.tenant_id
  }
  set {
    name  = "service.beta.kubernetes.io/azure-dns-label-name"
    value = var.dns_label == "" ? random_pet.this.id : var.dns_label
    type  = "string"
  }
}
