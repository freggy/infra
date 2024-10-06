#!/bin/bash
if [ $(cat /root/.joined) -eq 1 ]; then
    echo "already initialzed"
    exit 0
fi

kubeadm join --config /root/kubeadm_config.yaml

echo '1' > /root/.joined
