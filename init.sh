#!/bin/bash

resourceGroup=$1
clusterName=$2

echo "Resource Group: $resourceGroup"
echo "AKS cluster: $clusterName"

echo "====================="
echo "Installing Azure CLI"
echo "====================="
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 
az --version

echo "==========================="
echo "Installing kubectl client"
echo "==========================="
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

echo "==========================="
echo "Install jq for log parsing"
echo "==========================="
sudo apt install jq

echo "================================="
echo "Obtain KUBECONFIG through az CLI"
echo "================================="
az aks get-credentials --resource-group ${resourceGroup} --name ${clusterName} --file ${PWD}/${clusterName}.conf
