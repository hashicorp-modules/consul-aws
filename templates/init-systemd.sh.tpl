#!/bin/bash

echo "---Begin default init---"

echo "Set variables"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

echo "Set hostname"
hostnamectl set-hostname "${name}-consul-$${instance_id}"

echo "---Default init complete---"

echo "---Begin custom init---"
${user_data}
echo "---Custom init complete---"
