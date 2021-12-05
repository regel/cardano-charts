resource "random_password" "redis" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "helm_release" "csi" {
  name       = "csi-secrets-store-provider-azure"
  version    = "1.0.0"
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

locals {
  dns_label_name = var.dns_label == "" ? random_pet.this.id : var.dns_label
}


resource "helm_release" "cardano" {
  depends_on = [
    helm_release.csi,
    kubernetes_namespace.cardano
  ]

  name       = "testnet"
  repository = "https://regel.github.io/cardano-charts"
  chart      = "cardano"
  lint       = true
  namespace  = "testnet"
  create_namespace = true
  wait = false  # do not wait for readiness

  values = [
    <<EOF
secrets:
  redisUsername: "cardano"

redis:
  auth:
    username: "cardano"

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: "${helm_release.prometheus.namespace}"

vault:
  csi:
    enabled: true
    coldVaultName: "${azurerm_key_vault.cardano.name}"
    hotVaultName: "${azurerm_key_vault.cardano.name}"
    tenantId: "${var.tenant_id}"
    userAssignedIdentityID: "${azurerm_kubernetes_cluster.cardano.kubelet_identity[0].client_id}"

service:
  beta.kubernetes.io/azure-dns-label-name: "${local.dns_label_name}"

environment:
  name: testnet

persistence:
  enabled: true
  # -- Provide an existing `PersistentVolumeClaim`, the value is evaluated as a template.
  existingClaim:
  mountPath: /data
  # Starting in Kubernetes version 1.21, Kubernetes will use CSI drivers only and by default.
  storageClass: "managed-csi"
  accessModes:
    - ReadWriteOnce
  # -- PVC Storage Request for data volume
  size: 32Gi
  annotations: {}
  selector: {}
  sourceFile:
    enabled: true
    guid: 13ioPLPad3auIcBZgp5jJeukJcnq9_cTj
EOF
  ]

  set_sensitive {
    name  = "secrets.redisPassword"
    value = random_password.redis.result
  }
  set_sensitive {
    name  = "redis.auth.password"
    value = random_password.redis.result
  }
}
