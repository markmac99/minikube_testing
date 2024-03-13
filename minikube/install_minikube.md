# How to Install Minikube

**Note: all the steps below except the last one must be carried out on the host on which you're going to run Minikube.**

## Download software
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## Install as service
`minikube.service` starts Minikube as a systemd service. Edit to reflect the User and Group which will run minikube, then copy the service file to `/etc/systemd/system/` and enable & start the service. 
```
sudo cp minikube.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable minikube
sudo systemctl start minikube
```
Wait a couple of minute then check the service status.  
```
systemctl status minikube 
kubectl get pods -A
```
The latter should list a bunch of kube-system pods. 

## install OpenEBS
OpenEBS is a dynamic persistent volume service and is required by ARC. Its also useful for other stuff. To install it, run `install_openebs.sh`
```
kubectl get pods -A
```
should now show three additional pods in the openebs namespace.

## Install an nginx proxy for minikube
This allows you to connect to the cluster from other infrastructure on your network using kubectl or helm.  

Run the script `install_nginx_proxy.sh` to create a docker container with the required client certificates.
The container is started in the next section.

While running this script you will be prompted for a password. **Do not forget this!** as you will need it when configuring remote access (see below)

## Install the Dashboard and Proxy services
`minikube-dash.service` starts the Dashboard and the proxies to allow remote access to the cluster. 

Edit the service file to reflect the User and Group which will run minikube, and check that the paths in ExecStart and ExecStop point to the location of the dashboard start/stop scripts on your minikube server. 

Now copy the service file to `/etc/systemd/system/` and enable & start. 
```
sudo cp minikube-dash.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable minikube-dash
sudo systemctl start minikube-dash
```
Wait a couple of minute then check the service status
```
systemctl status minikube-dash
kubectl get pods -A
```
Don't worry if you get  `context cancelled` messages from the proxy, this is normal. 
Kubectl should show two new pods in the `kubernetes-dashboard` namespace. 

## Accesing the Dashboard
This will be found at
http://yourserver:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy

## Accessing the cluster remotely with Helm and Kubectl
First install helm and kubectl on your PC. They can be downloaded from the helm and minikube websites.

Now follow these steps:
* On the minikube host, run the following to obtain a CA certificate, replacing `clusname` with your cluster's name. 
```
kubectl get cm kube-root-ca.crt -o jsonpath="{['data']['ca\.crt']}" > /tmp/ca-clusname.crt
```
* Now on your PC, create a folder `$HOME/.minikube/profiles/yourclustername`  and copy the CA certificate you created in the previous step to it. If you're on Windows, $HOME is c:\users\yourid.
  
* run `kubectl config view` on your PC. The result should be empty unless you're already accessing other Kubernetes clusters.

* run the following commands to create a cluster and context for your cluster, replacing `clusname` and `hostname` with your cluster's name and hostname, and replacing `password` with the Nginx proxy password you created earlier
```
kubectl config set-cluster clusname --server=clusname:password@hostname:443 --certificate-authority "$HOME/.minikube/ca-clusname.crt"
kubectl config set-context clusname --cluster clusname --namespace default --user minikube
kubectl config use-context clusname
```

You should now be able to list pods on your cluster:
```
kubectl get pods -n kube-system
NAME                               READY   STATUS    RESTARTS       AGE
coredns-5dd5756b68-rrqf8           1/1     Running   0              112m
etcd-minikube                      1/1     Running   0              112m
...
```