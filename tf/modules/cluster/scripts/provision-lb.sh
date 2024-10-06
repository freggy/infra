#!/bin/bash
apt update
apt-get install haproxy -y

curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --auth-key=$TAILSCALE_AUTH_KEY
