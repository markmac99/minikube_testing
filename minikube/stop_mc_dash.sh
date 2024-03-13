#!/bin/bash

prxpid=$(ps -ef | egrep "kubectl proxy" | grep -v grep |awk '{print $2}')
[ "$prxpid" != "" ] && kill -9 $prxpid ; echo "stopped proxy" || echo "proxy not running"

dashpid=$(ps -ef | grep kubernetes-dashboard | grep -v grep |awk '{print $2}')
[ "$dashpid" != "" ] && kill -9 $dashpid ; echo "stopped dashboard" || echo "dashboard not running"

