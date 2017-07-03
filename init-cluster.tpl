#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
new_hostname="consul-$${instance_id}"

# stop consul so it can be configured correctly
systemctl stop consul

# clear the consul data directory ready for a fresh start
rm -rf /opt/consul/data/*

# set the hostname (before starting consul)
hostnamectl set-hostname "$${new_hostname}"

# seeing failed nodes listed  in consul members with their solo config
# try a 2 min sleep to see if it helps with all instances wiping data
# in a similar time window
sleep 120

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"Environment-Name\", \"tag_value\": \"${environment_name}\"}" < /etc/consul.d/consul-default.json > /tmp/consul-default.json.tmp
sed -i -e "s/127.0.0.1/$${local_ipv4}/" /tmp/consul-default.json.tmp
mv /tmp/consul-default.json.tmp /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

# add the cluster instance count to the config with jq
jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json > /tmp/consul-server.json.tmp
mv /tmp/consul-server.json.tmp /etc/consul.d/consul-server.json
chown consul:consul /etc/consul.d/consul-server.json

# start consul once it is configured correctly
systemctl start consul
