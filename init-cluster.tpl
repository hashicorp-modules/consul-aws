#!/bin/bash

echo "
{
  \"server\": true,
  \"bootstrap_expect\": ${cluster_size},
  \"retry_join_ec2\": {
     \"tag_key\": \"Cluster-Name\",
     \"tag_value\": \"${cluster_name}\"
  }
}
" > /etc/consul.d/consul-server.json
systemctl enable consul
systemctl start consul
