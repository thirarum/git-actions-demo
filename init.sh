#!/bin/bash

resourceGroup=$1
clusterName=$2

echo "Resource Group: $resourceGroup"
echo "AKS cluster: $clusterName"

echo "====================="
echo "Installing Azure CLI"
echo "====================="
curl -sL https://aka.ms/InstallAzureCLIDeb | bash 
az --version
az aks get-versions -l eastus -o table

echo "==========================="
echo "Installing kubectl client"
echo "==========================="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

echo "==========================="
echo "Install jq for log parsing"
echo "==========================="
apt install jq

echo "================================="
echo "Obtain KUBECONFIG through az CLI"
echo "================================="
az aks get-credentials --resource-group ${resourceGroup} --name ${clusterName} --file ${PWD}/${clusterName}.conf
