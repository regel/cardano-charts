#!/bin/bash

environment=testnet
spName=tf-sp-$environment
TENANT_ID=$(az account show --query tenantId -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

TF_SP_SECRET=$(az ad sp create-for-rbac -n $spName --role Contributor --query password -o tsv)
TF_SP_ID=$(az ad sp list --display-name $spName --query [0].appId -o tsv)
