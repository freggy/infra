#!/bin/bash
kubeadm init \
    --config /root/kubeadm_config.yaml \
    --upload-certs \

echo '1' > /root/.joined
