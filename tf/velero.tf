
locals {
  storage_account_name = format("velero%s", random_string.velero.id)
  credentials = <<EOF
AZURE_SUBSCRIPTION_ID = ${try(data.azurerm_subscription.current.subscription_id, "")}
AZURE_TENANT_ID = ${try(data.azurerm_subscription.current.tenant_id, "")}
AZURE_RESOURCE_GROUP = ${azurerm_kubernetes_cluster.cardano.node_resource_group}
AZURE_CLIENT_ID = ${try(var.velero_client_id, "")}
AZURE_CLIENT_SECRET = ${try(var.velero_client_secret, "")}
AZURE_CLOUD_NAME = AzurePublicCloud
EOF
}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

resource "kubernetes_secret" "velero" {
  metadata {
    name      = "cloud-credentials"
    namespace = kubernetes_namespace.velero.metadata[0].name
  }
  data = {
    cloud = local.credentials
  }
}

resource "random_string" "velero" {
  length           = 9
  special          = false
  lower            = false
  upper            = false
  number           = true
}

resource "azurerm_storage_account" "velero" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.cardano.name
  location                 = azurerm_resource_group.cardano.location
  account_tier             = "Standard"
  access_tier              = "Cool"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "velero" {
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}

resource "helm_release" "velero" {
  name       = "velero"
  depends_on = [
    kubernetes_secret.velero,
    kubernetes_namespace.velero,
    azurerm_storage_account.velero,
  azurerm_storage_container.velero]
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  lint       = false
  namespace  = "velero"
  create_namespace = true

  values = [
    <<EOF
credentials:
  existingSecret: "cloud-credentials"
configuration:
  features: "EnableCSI"
  provider: "azure"
  backupStorageLocation:
    bucket: "${azurerm_storage_container.velero.name}"
    config:
      resourceGroup: "${azurerm_resource_group.cardano.name}"
      storageAccount: "${azurerm_storage_account.velero.name}"
  volumeSnapshotLocation:
    config:
      subscriptionId: "${data.azurerm_subscription.current.subscription_id}" 
      resourceGroup: "${azurerm_resource_group.cardano.name}"
initContainers:
  - name: velero-plugin-for-microsoft-azure
    image: velero/velero-plugin-for-microsoft-azure:v1.3.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
  - name: velero-plugin-for-csi
    image: velero/velero-plugin-for-csi:v0.2.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
  ]
}

