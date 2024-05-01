#!/bin/bash
$JOIN_CMD \
    --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables \
    --certificate-key $CERT_KEY \

echo '1' > /root/.joined