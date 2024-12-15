#!/bin/sh
set -ex;

export YOUR_PUBLIC_HOSTNAME=$(curl --max-time 1 -s 'https://checkip.amazonaws.com' 2>/dev/null)
echo ">> Running with public hostname as : $YOUR_PUBLIC_HOSTNAME"

docker compose up # Start wireguard server
