#!/bin/bash

service consul stop

internalIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
instanceID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
hostname="consul-$${instanceID#*-}"

hostnamectl set-hostname $hostname

aws ec2 describe-instances --region ${region} --filters 'Name=tag:Cluster-Name,Values=${cluster_name}' 'Name=instance-state-name,Values=running' | jq -r '.Reservations[].Instances[].PrivateIpAddress' > /tmp/instances

while read line;
do
 if [ "$line" != "$internalIP" ]; then
    echo "Adding address $${line}"
    cat /etc/consul/000-consul.json | jq ".retry_join += [\"$${line}\"]" > /tmp/$${line}-consul.json

    if [ -s /tmp/$${line}-consul.json ]; then
        cp /tmp/$${line}-consul.json /etc/consul/000-consul.json
    fi
 fi
done < /tmp/instances

rm -f /tmp/instances

# Clear any old state from the build process
rm -rf /opt/consul/data/*

service consul start
