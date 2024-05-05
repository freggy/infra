#!/bin/bash
if [ $(cat /root/.joined) -eq 1 ]; then
    echo "already initialzed"
    exit 0
fi

if [ -z $IS_CP ]; then
    $JOIN_CMD \
        --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables \
        --certificate-key $CERT_KEY
else
    $JOIN_CMD \
        --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables \
        --certificate-key $CERT_KEY \
        --control-plane
fi

echo '1' > /root/.joined