#!/bin/bash

instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
new_hostname="consul-$${instance_id}"

# set the hostname (before starting consul)
hostnamectl set-hostname "$${new_hostname}"

# add the consul group to the config with jq
jq ".retry_join_ec2 += {\"tag_key\": \"consul_retry_join_ec2\", \"tag_value\": \"${consul_retry_join_ec2}\"}" < /etc/consul.d/consul-default.json > /tmp/consul-default.tmp

# add the cluster instance count to the config with jq
jq ".bootstrap_expect = ${cluster_size}" < /etc/consul.d/consul-server.json > /tmp/consul-server.tmp

# cp rather than mv to maintain owner and permissions on files
cp /tmp/consul-default.tmp /etc/consul.d/consul-default.json
cp /tmp/consul-server.tmp /etc/consul.d/consul-server.json

systemctl enable consul
systemctl start consul
