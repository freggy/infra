#!/bin/bash
# ignore FileContent--proc-sys-net-bridge-bridge-nf-call-iptables
# because we are using ciliums kube-proxy replacement which does
# not use iptables
kubeadm init \
    --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables \
    --skip-phases=addon/kube-proxy \
    --config /root/cluster_config.yaml \
    --upload-certs \

echo '1' > /root/.joined