#!/bin/bash

resourceGroup=$1
clusterName=$2

echo "AKS cluster: $clusterName"

echo "========================"
echo "Check Azure CLI version"
echo "========================"
az --version

echo "==========================="
echo "Installing kubectl client"
echo "==========================="
az aks install-cli
echo "kubectl version"
ret=$(kubectl --help)
kubectl version --client

echo "==========================="
echo "Install jq for log parsing"
echo "==========================="
JQ=/usr/bin/jq
curl https://stedolan.github.io/jq/download/linux64/jq > $JQ && chmod +x $JQ
ls -la $JQ

echo "================================="
echo "Obtain KUBECONFIG through az CLI"
echo "================================="
az aks get-credentials --resource-group ${resourceGroup} --name ${clusterName} --file ${PWD}/${clusterName}.conf
