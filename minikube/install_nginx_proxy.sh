#!/bin/bash

# run this on the server where minikube is installed. It copies the cert files
# from the user's minikube profile.

cd nginx
mkdir minikube
cp ~/.minikube/profiles/minikube/client.* ./minikube
sudo apt install apache2-util
htpasswd -c nginx/minikube/.htpasswd minikube

docker build -t nginx-minikube-proxy .

# docker run -d --rm --memory="500m" --memory-reservation="256m" --cpus="0.25" --name nginx-minikube-proxy -p 443:443 -p 80:80 --network=minikube nginx-minikube-proxy
