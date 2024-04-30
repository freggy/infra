#!/bin/bash
if [ $(cat /root/.joined) -eq 1 ]; then
    echo "already initialzed"
    exit 0
fi

#certkey=$(kubeadm certs certificate-key)
$JOIN_CMD \
    --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables \
    --certificate-key $CERT_KEY \
    --control-plane \
