#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="consul-$${instance_id}"

# set the hostname (before starting consul)
hostnamectl set-hostname "$${new_hostname}"

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"Environment-Name\", \"tag_value\": \"${environment_name}\"}" < /etc/consul.d/consul-default.json.example > /etc/consul.d/consul-default.json
chown consul:consul /etc/consul.d/consul-default.json

# add the cluster instance count to the config with jq
jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json.example > /etc/consul.d/consul-server.json
chown consul:consul /etc/consul.d/consul-server.json

systemctl enable consul
systemctl start consul
