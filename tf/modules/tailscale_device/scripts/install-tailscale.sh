curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list

apt-get update
apt-get install tailscale -y

# explicitly set hostname here, because under certain circumstances
# it can make sense to have a different hostname in tailscale
# than what is configured on the node.
#
# currently we utilize this, so hosts can have the same hostname
# in different environments. enviroments are identified by their
# dns zone, but this will not be reflected in tailscales UI, so
# we append the environment to the name.
tailscale up --hostname=$HOSTNAME --auth-key=$TAILSCALE_AUTH_KEY
