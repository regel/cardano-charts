#!/bin/bash -x
#
# Usage:
#    install.sh [-u] [ -n NAMESPACE ] [ -r RELEASE ] [-k kes.skey] [-v vrf.skey] [-c node.cert]
#
set -eu

usage() {
  echo "$0 [-u] [ -n NAMESPACE ] [ -r RELEASE ] [-k kes.skey] [-v vrf.skey] [-c node.cert]"

  echo "Description of options:"
  echo "  -n: Set namespace. Default: testnet"
  echo "  -r: Set release name. Default: testnet"
  echo "  -k: KES skey file. Default: kes.skey"
  echo "  -v: VRF skey file. Default: vrf.skey"
  echo "  -c: Node certificate file. Default: node.cert"
  echo "  -u: Uninstall"
}

exit_abnormal() {
  usage
  exit 1
}

NAMESPACE=testnet
RELEASE=testnet
UNINSTALL=0
KES_SKEY=""
VRF_SKEY=""
NODE_CERT=""

while getopts ":n:r:h:uc:k:v:" options; do
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
    c)
      NODE_CERT=${OPTARG}
      ;;
    k)
      KES_SKEY=${OPTARG}
      ;;
    v)
      VRF_SKEY=${OPTARG}
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
KES_SKEY=${KES_SKEY:-kes.skey}
VRF_SKEY=${VRF_SKEY:-vrf.skey}
NODE_CERT=${NODE_CERT:-node.cert}

if [ $UNINSTALL -ne 0 ]; then
  helm -n "$NAMESPACE" uninstall "$RELEASE"
  exit $?
fi

[[ -f "$KES_SKEY" ]] \
  || { echo "File not found: $KES_SKEY" ; exit_abnormal; } >&2
[[ -f "$VRF_SKEY" ]] \
  || { echo "File not found: $VRF_SKEY" ; exit_abnormal; } >&2
[[ -f "$NODE_CERT" ]] \
  || { echo "File not found: $NODE_CERT" ; exit_abnormal; } >&2

KES_SKEY=$(realpath "$KES_SKEY")
VRF_SKEY=$(realpath "$VRF_SKEY")
NODE_CERT=$(realpath "$NODE_CERT")

REDIS_USERNAME=${REDIS_USERNAME:-cardano}
REDIS_PASSWORD=$(kubectl get secret --namespace "$NAMESPACE" "${RELEASE}-auth" -o jsonpath="{.data.redis-password}" | base64 -d)
if [ -z "$REDIS_PASSWORD" ]; then
  REDIS_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1)
fi
echo hello
kubectl create namespace "$NAMESPACE" || true
(
cd cardano
VALUES_FILE="values-${RELEASE}.yaml"
if [ ! -f "$VALUES_FILE" ]; then
  echo "Warn: Cannot find file ${VALUES_FILE}. Using defaults" >&2
  VALUES_FILE="values.yaml"
fi
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dep update
helm install prometheus bitnami/kube-prometheus -n prometheus
helm upgrade --install "$RELEASE" \
  --namespace $NAMESPACE \
  --values "$VALUES_FILE" \
  --set secrets.redisUsername="$REDIS_USERNAME" \
  --set secrets.redisPassword="$REDIS_PASSWORD" \
  --set redis.auth.username="$REDIS_USERNAME" \
  --set redis.auth.password="$REDIS_PASSWORD" \
  --set-file secrets.kesSkey=$KES_SKEY \
  --set-file secrets.vrfSkey=$VRF_SKEY \
  --set-file secrets.nodeCert=$NODE_CERT \
  --set metrics.enabled=true \
  --set metrics.serviceMonitor.enabled=true \
  --set metrics.serviceMonitor.namespace=prometheus \
  .
)

exit 0
