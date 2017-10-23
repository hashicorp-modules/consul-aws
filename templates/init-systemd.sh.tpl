#!/bin/bash

echo "Set variables"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

echo "Set hostname"
hostnamectl set-hostname "${name}-$${instance_id}"

echo "Configure Consul server"
cat <<EOF >/etc/consul.d/consul-server.json
{
  "datacenter": "${name}",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "server": true,
  "bootstrap_expect": ${consul_count},
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=Consul-Auto-Join tag_value=${name}"]
}
EOF

echo "Update configuration file permissions"
chown -R consul:consul /etc/consul.d
chmod -R 0644 /etc/consul.d/*

echo "Don't start Consul in -dev mode"
echo '' | sudo tee /etc/consul.d/consul.conf

echo "Restart Consul"
systemctl restart consul
