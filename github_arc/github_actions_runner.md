# Setting up a GitHub Actions Runner Controller (ARC) and Scaleset
https://github.com/actions/actions-runner-controller/blob/master/docs/quickstart.md

## Prerequisites

### Software and Access
* you need a kubernetes cluster, eg minikube
* you need to have already downloaded `helm` and `kubectl` 

### Get a PAT from github 
This is configured in your developer settings in Github. I recommend storing your PAT in ~/.ssh/gh_pat_containers, then setting permissions on the file to 0600 for security. The scripts in this folder assume the PAT is stored there.

## Create the controller
The script `install_arc.sh` creates and installs the ARC pods and dependencies, `cert-manager` and the helm repo from which ARC is pulled. Feel free to read through the script but in summary it: 
* reads in the Github PAT
* installs or updates the Helm repository, as necessary
* installs the latest version of `cert-manager` in Kubernetes
* installs or updates the ARC deployment in Kubernetes

After running it, you should have several new pods:
```
kubectl get pods -A | egrep "arc-controller|cert-manager"
arc-controller         arc-gha-rs-controller-58f9bc9fbb-hddj8         1/1     Running   0             2m51s
cert-manager           cert-manager-67c98b89c8-456w8                  1/1     Running   0             3m2s
cert-manager           cert-manager-cainjector-5c5695d979-fjcjz       1/1     Running   0             3m2s
cert-manager           cert-manager-webhook-7f9f8648b9-h2hsc          1/1     Running   0             3m1s
```

## Scalesets
Now you can ceate a scaleset and register it against your code repository. Scalesets are repository-specific but an example script to create one is in this repository. Note the following:  
* INSTALLATION_NAME is the value you use for "runs-on" in an Action.
* NAMESPACE should be repo-specific to segregate pods and runners.

After you create the scaleset, you should see a new pod appear in the `arc-controller` namespace, and a scaleset runner appear in your Github repository. 

### Overriding Scaleset Defaults
To override the default values, use a repository-specific `values.yaml` file. The scope of this is beyond this brief
introduction, though examples can be found in some of my other repositories. 

As one example: you can override the default actions-runner container with your own. An example of the dockerfile template for building a suitable container is in the `mm-arc-runner` folder. 