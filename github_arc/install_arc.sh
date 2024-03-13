#!/bin/bash

# the GH PAT is stored safely
if [ ! -f ~/.ssh/gh_pat_containers ] ; then
    echo "First save your github PAT in ~/.ssh/gh_pat_containers and set its permissions to 0600"
    exit
fi
GITHUB_PAT=$(cat ~/.ssh/gh_pat_containers)

# add the required Helm repo
helm repo list  | grep actions-runner > /dev/null
if [ $? -ne 0 ] ; then 
    helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
fi
helm repo update

# install the latest cert-manager as required by ARC
latest=$(curl -s  "https://api.github.com/repos/cert-manager/cert-manager/releases/latest" | jq -r '.name')
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${latest}/cert-manager.yaml

# finally install the ARC deployment
NAMESPACE="arc-controller"
helm upgrade --install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set=authSecret.create=true \
    --set=authSecret.github_token="${GHPAT}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
