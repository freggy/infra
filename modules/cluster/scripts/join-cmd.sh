#!/bin/bash
set -e

# Extract "ip" argument from the input into IP shell variable
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "IP=\(.ip)"')"
CMD=$(ssh -o StrictHostKeyChecking=no root@$IP 'kubeadm token create --print-join-command')

jq -n --arg cmd "$CMD" '{"cmd":$cmd}'