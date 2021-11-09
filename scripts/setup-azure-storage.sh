#!/bin/bash

environment=testnet
TFSTATE_RESOURCE_GROUP_NAME=tfstate-$environment
TFSTATE_STORAGE_ACCOUNT_NAME=tfstate$RANDOM$environment
TFSTATE_BLOB_CONTAINER_NAME=tfstate-$environment

az group create -n $TFSTATE_RESOURCE_GROUP_NAME -l eastus
az storage account create -g $TFSTATE_RESOURCE_GROUP_NAME -n $TFSTATE_STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
TFSTATE_STORAGE_ACCOUNT_KEY=$(az storage account keys list -g $TFSTATE_RESOURCE_GROUP_NAME --account-name $TFSTATE_STORAGE_ACCOUNT_NAME --query [0].value -o tsv)
az storage container create -n $TFSTATE_BLOB_CONTAINER_NAME --account-name $TFSTATE_STORAGE_ACCOUNT_NAME --account-key $TFSTATE_STORAGE_ACCOUNT_KEY

az group lock create --lock-type CanNotDelete -n CanNotDelete -g $TFSTATE_RESOURCE_GROUP_NAME

