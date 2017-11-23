#!/bin/bash

echo "---Begin default init---"

echo "Set variables"
instance_id="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
hostname=${name}-consul-$${instance_id}

echo "Set hostname"

YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z $${YUM} ]]; then
  hostnamectl set-hostname "$${hostname}"
elif [[ ! -z $${APT_GET} ]]; then
  sudo hostname $${hostname}
  sudo sed -i '2i127.0.1.1 $${hostname}' /etc/hosts
  echo '$${hostname}' | sudo tee /etc/hostname
else
  echo "OS detection failure"
fi

echo "---Default init complete---"

echo "---Begin custom init---"
${user_data}
echo "---Custom init complete---"
