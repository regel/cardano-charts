#!/bin/bash -x
#
# Usage:
#    install.sh [-u] [ -n NAMESPACE ] [ -r RELEASE ] [-h hostName] [-v vaultName] [-i managedIdentityId] [-t tenantId]
#
set -eu

usage() {
  echo "$0 [-u] [ -n NAMESPACE ] [ -r RELEASE ] [-h hostName] [-v vaultName] [-i managedIdentityId] [-t tenantId]"

  echo "Description of options:"
  echo "  -n: Set namespace. Default: testnet"
  echo "  -r: Set release name. Default equals to the namespace"
  echo "  -h: DNS name label"
  echo "  -v: Azure Vault name"
  echo "  -i: Azure User Managed Identity identifier"
  echo "  -t: Azure Tenant Id"
  echo "  -u: Uninstall"
}

exit_abnormal() {
  usage
  exit 1
}

NAMESPACE=testnet
RELEASE=""
HOSTNAME=stupidchess
UNINSTALL=0
TENANT_ID=""
VAULT_NAME=""
MANAGED_IDENTITY=""

while getopts ":n:r:h:uv:i:t:" options; do
  case "${options}" in
    u)
      UNINSTALL=1
      ;;
    n)
      NAMESPACE=${OPTARG}
      ;;
    r)
      RELEASE=${OPTARG}
      ;;
    h)
      HOSTNAME=${OPTARG}
      ;;
    i)
      MANAGED_IDENTITY=${OPTARG}
      ;;
    v)
      VAULT_NAME=${OPTARG}
      ;;
    t)
      TENANT_ID=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument." >&2
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done
RELEASE=${RELEASE:-"$NAMESPACE"}

if [ $UNINSTALL -ne 0 ]; then
  helm -n "$NAMESPACE" uninstall "$RELEASE"
  exit $?
fi

[[ -n "$HOSTNAME" ]] \
  || { echo "Undefined DNS host name label" ; exit_abnormal; } >&2
[[ -n "$TENANT_ID" ]] \
  || { echo "Undefined tenant id" ; exit_abnormal; } >&2
[[ -n "$VAULT_NAME" ]] \
  || { echo "Undefined vault name" ; exit_abnormal; } >&2
[[ -n "$MANAGED_IDENTITY" ]] \
  || { echo "Undefined managed identity" ; exit_abnormal; } >&2


REDIS_USERNAME=${REDIS_USERNAME:-cardano}
REDIS_PASSWORD=$(kubectl get secret --namespace "$NAMESPACE" "${RELEASE}-auth" -o jsonpath="{.data.redis-password}" | base64 -d)
if [ -z "$REDIS_PASSWORD" ]; then
  REDIS_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1)
fi
kubectl create namespace "$NAMESPACE" || true
(
cd cardano
VALUES_FILE="values-${RELEASE}.yaml"
if [ ! -f "$VALUES_FILE" ]; then
  { echo "Error: Cannot find file ${VALUES_FILE}" ; exit_abnormal; } >&2
fi
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dep update
helm install prometheus bitnami/kube-prometheus -n prometheus || true
helm upgrade --install "$RELEASE" \
  --namespace $NAMESPACE \
  --values "$VALUES_FILE" \
  --set secrets.redisUsername="$REDIS_USERNAME" \
  --set secrets.redisPassword="$REDIS_PASSWORD" \
  --set redis.auth.username="$REDIS_USERNAME" \
  --set redis.auth.password="$REDIS_PASSWORD" \
  --set service.beta.kubernetes.io/azure-dns-label-name="$HOSTNAME" \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true \
  --set metrics.serviceMonitor.namespace=prometheus \
  --set vault.csi.enabled=true \
  --set vault.csi.coldVaultName="$VAULT_NAME" \
  --set vault.csi.hotVaultName="$VAULT_NAME" \
  --set vault.csi.userAssignedIdentityID="$MANAGED_IDENTITY" \
  --set vault.csi.tenantId="$TENANT_ID" \
  .
)

exit 0
