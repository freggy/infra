#!/bin/bash
echo Waiting for tailscale0 to get an IP address...
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  if ip addr show dev tailscale0 | grep -q 'inet '; then break; fi
  echo $i
  sleep 1
done
