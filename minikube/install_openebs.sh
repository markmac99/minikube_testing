#!/bin/bash

# NB: openEBS requires /run/udev to be mounted in mniikube - see minikube startup scriopts

helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install openebs openebs/openebs -n openebs --create-namespace
