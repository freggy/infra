#!/bin/bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
ARCH=$(dpkg --print-architecture)
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-linux-$ARCH.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-$ARCH.tar.gz.sha256sum
tar -C /usr/local/bin -xzvf cilium-linux-$ARCH.tar.gz
rm cilium-linux-$ARCH.tar.gz{,.sha256sum}
KUBECONFIG=/etc/kubernetes/admin.conf cilium install \
    --version $CILIUM_VERSION \
    --set k8sServiceHost=95.217.174.130 \
    --set k8sServicePort=6443 \
    --set kubeProxyReplacement=true \
    --wait \
    --wait-duration 30s \

