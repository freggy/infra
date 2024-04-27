#!/bin/bash
# MAJOR_VERSION -> v1.29
# FULL_VERSION  -> v1.29.4-150500.2.1

cat <<EOF | tee /etc/zypp/repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$MAJOR_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$MAJOR_VERSION/rpm/repodata/repomd.xml.key
EOF

cat <<EOF | tee /etc/zypp/repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/stable:/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/stable:/rpm/repodata/repomd.xml.key
EOF 

# TODO: hold packages
transactional-update --continue pkg install -y cri-o kubelet=$FULL_VERSION kubeadm=$FULL_VERSION kubectl=$FULL_VERSION
transactional-update apply
