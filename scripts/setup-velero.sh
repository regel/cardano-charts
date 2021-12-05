#!/bin/bash -x
# Creates a custom Rbac role for Velero with minimum permissions

NAME="Velero Snapshot Operator"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

az role definition list --name "$NAME" -o tsv | grep -q "$NAME"
if [ $? -ne 0 ]; then
  az role definition update --role-definition "{
      \"Name\": \"$NAME\",
      \"IsCustom\": true,
      \"Description\": \"Can snapshot PV in AKS clusters.\",
      \"Actions\": [
        \"Microsoft.Compute/disks/read\",
        \"Microsoft.Compute/disks/write\",
        \"Microsoft.Compute/disks/endGetAccess/action\",
        \"Microsoft.Compute/disks/beginGetAccess/action\",
        \"Microsoft.Compute/snapshots/read\",
        \"Microsoft.Compute/snapshots/write\",
        \"Microsoft.Compute/snapshots/delete\",
        \"Microsoft.Compute/disks/beginGetAccess/action\",
        \"Microsoft.Compute/disks/endGetAccess/action\",
        \"Microsoft.Storage/storageAccounts/listKeys/action\"
      ],
      \"NotActions\": [
      ],
      \"AssignableScopes\": [\"/subscriptions/$SUBSCRIPTION_ID\"]
    }"
fi

spName=sp-velero
TF_SP_SECRET=$(az ad sp create-for-rbac -n $spName --role "$NAME" --query password -o tsv)
TF_SP_ID=$(az ad sp list --display-name $spName --query [0].appId -o tsv)
