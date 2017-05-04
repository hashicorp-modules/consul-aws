#!/bin/bash

local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="consul-$${instance_id}"

# set the hostname (before starting consul)
hostnamectl set-hostname "$${new_hostname}"

# get the list of ip addresses for running instances in this cluster
aws ec2 describe-instances --region ${region} --filters 'Name=tag:Cluster-Name,Values=${cluster_name}' 'Name=instance-state-name,Values=running' | jq '.Reservations[].Instances[].PrivateIpAddress' > /tmp/instance_ips.tmp

# assign a variable with the formatted list of ip addresses
instance_ips=$(paste -s -d, /tmp/instance_ips.tmp)

# add the instance ips to the config with jq
jq ".retry_join += [$${instance_ips}]" < /etc/consul.d/consul-default.json > /tmp/consul-default.tmp

# cp rather than mv to maintain owner and permissions on /etc/consul.d/consul-default.json
cp /tmp/consul-default.tmp /etc/consul.d/consul-default.json

systemctl enable consul
systemctl start consul
