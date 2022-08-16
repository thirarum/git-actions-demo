#!/bin/bash

resourceGroup=$1
aksClusterName=$2
vzVersion=$3
vzProfile=$4

echo "RG: $resourceGroup"
echo "AKS cluster: $aksClusterName"

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
az aks get-credentials --resource-group ${resourceGroup} --name ${aksClusterName} --file ${PWD}/${aksClusterName}.conf

echo "==================="
echo "Install Verrazzano"
echo "==================="

export KUBECONFIG=${PWD}/${aksClusterName}.conf

kubectl version 
result=$?

if [ "$result" != "0" ];
then
    echo "OKE Cluster not configured properly!!!"
    exit 1
fi

kubectl get nodes -o wide

echo "Install Verrazzano Platform Operator"
kubectl apply -f https://github.com/verrazzano/verrazzano/releases/download/${vzVersion}/operator.yaml

sleep 5

echo "Waiting for VZ operator installation to be completed..."
kubectl -n verrazzano-install rollout status deployment/verrazzano-platform-operator

echo "Install Verrazzano using '${vzProfile}' profile"
kubectl apply -f - <<EOF
apiVersion: install.verrazzano.io/v1alpha1
kind: Verrazzano
metadata:
  name: aks-verrazzano
spec:
  profile: ${vzProfile:-dev}
EOF

sleep 10

VZ_STATE=$(kubectl get verrazzano | grep aks-verrazzano | awk {'print $2'})
echo "Verrazzano CRD status: $VZ_STATUS"

wait_time=$(date -ud "45 minute" +%s)

while [[ "${VZ_STATE}" != "InstallComplete" ]];
do
    if [ $(date -u +%s) -gt $wait_time ];
    then
       echo "Verrazzano installation is not complete even after 45 mins !!"
       exit 1
    fi
    # echo "Waiting for Verrazzano installation to be completed..."
    sleep 20s
    kubectl get verrazzano
    VZ_STATE=$(kubectl get verrazzano | grep aks-verrazzano | awk {'print $2'})

    if [ "${VZ_STATE}" == "InstallFailed" ];
    then
       echo "Verrazzano installation failed!"
       kubectl -n verrazzano-install logs -f $(kubectl -n verrazzano-install get pods | grep verrazzano-platform-operator |  awk {'print $1'})
       exit 1
    fi
done

echo "=================================================="
echo "Verrazzano installation completed!"
kubectl get verrazzano
echo "=================================================="

echo "Get console URLs"
kubectl get vz -o jsonpath="{.items[].status.instance}" | jq .

VZ_CONSOLE_URL=$( \
    kubectl get ingress -n verrazzano-system 2>&1 | \
        grep verrazzano-ingress | \
        awk {'print $3'} \
    )

KEYCLOAK_CONSOLE_URL=$( \
    kubectl get ingress -n keycloak 2>&1 | \
        grep keycloak | awk {'print $3'} \
    )
    
CONSOLE_PWD=$( \
    kubectl get secret \
        --namespace verrazzano-system verrazzano -o jsonpath={.data.password} | base64 --decode; echo \
    )

KEYCLOAK_CONSOLE_STATUS=$(curl -k -s -I https://${KEYCLOAK_CONSOLE_URL} | awk {'print $2'} | head -n 1)
echo "Keycloak console status: $KEYCLOAK_CONSOLE_STATUS"

if [ "${KEYCLOAK_CONSOLE_STATUS}" != "200" ];
then
    echo "Error getting Keycloak console!!!"
    exit 1
fi

echo "============================================="
echo "Verrazzano console url: https://${VZ_CONSOLE_URL}"
echo "Verrazzano console password: ${CONSOLE_PWD}"
echo "============================================="

# Writing output to Azure CLI output
result=$(echo "{ \"Verrazzano console url\": \"https://${VZ_CONSOLE_URL}\",  \"Verrazzano console password\": \"${CONSOLE_PWD}\" }")
echo $result > $AZ_SCRIPTS_OUTPUT_PATH

