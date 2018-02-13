#!/bin/bash

echo "[---Begin init-systemd.sh---]"

echo "Set variables"
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
HOSTNAME=${name}-consul-$INSTANCE_ID

echo "Set hostname"

YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z $${YUM} ]]; then
  hostnamectl set-hostname "$HOSTNAME"
elif [[ ! -z $${APT_GET} ]]; then
  sudo hostname $HOSTNAME
  sudo sed -i "2i127.0.1.1 $HOSTNAME" /etc/hosts
  echo $HOSTNAME | sudo tee /etc/hostname
else
  echo "OS detection failure"
fi

echo "[---init-systemd.sh complete---]"

echo "[---Begin custom init---]"
${user_data}
echo "[---Custom init complete---]"
