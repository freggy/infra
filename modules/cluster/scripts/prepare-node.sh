#!/bin/bash
# MAJOR_VERSION -> 1.29
# FULL_VERSION  -> 1.29.4-150500.2.1

# kubernetes repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$MAJOR_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$MAJOR_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# crio repo
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v$MAJOR_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v$MAJOR_VERSION/deb/ /" | tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl
apt-mark hold cri-o kubelet kubeadm kubectl
systemctl start crio.service

sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf # persist after reboot

# this indicates that if the node is a control plane 
# it has not been initialized
echo '0' > /root/.joined