#!/bin/bash

local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="consul-$${instance_id}"

hostnamectl set-hostname "$${new_hostname}"

aws ec2 describe-instances --region ${region} --filters 'Name=tag:Cluster-Name,Values=${cluster_name}' 'Name=instance-state-name,Values=running' | jq -r '.Reservations[].Instances[].PrivateIpAddress' > /tmp/instance_ips

systemctl enable consul
systemctl start consul

# while read instance_ip; do
#   if [ "$${instance_ip}" != "$${local_ipv4}" ]; then
#     consul join $${instance_ip}
#   fi
# done < /tmp/instance_ips

# rm /tmp/instance_ips
