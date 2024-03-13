#!/bin/bash

dashpid=$(ps -ef | grep kubernetes-dashboard | grep -v grep |awk '{print $2}')
if [ "$dashpid" == "" ]  ; then 
	minikube dashboard  --url &
	sleep 30 
else
	 echo "dashboard already running on $dashpid"
fi

prxpid=$(ps -ef | egrep "kubectl proxy" | grep -v grep |awk '{print $2}')
if [ "$prxpid" == "" ] ; then 
	kubectl proxy --address='0.0.0.0' --accept-hosts='^*$' &
else
	echo "proxy already running on $prxpid"
fi 
nginxprx=$(docker ps | grep nginx-minikube-proxy | awk '{print $1}')
if [ "$nginxprx" == ""  ]; then
	docker run -d --rm --memory="500m" --memory-reservation="256m" --cpus="0.25" --name nginx-minikube-proxy -p 443:443 -p 80:80 --network=minikube nginx-minikube-proxy	
else
	echo "remote proxy already running as $nginxprx"
fi 
# minikube mount /run/udev:/run/udev & 
