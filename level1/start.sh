#!/bin/sh
set -ex;

# Lookup your public ip
export LEVEL1_PUBLIC_FACING_IP_OR_HOST=$(curl --max-time 1 -s 'https://checkip.amazonaws.com' 2>/dev/null || echo "")
[ "$LEVEL1_PUBLIC_FACING_IP_OR_HOST" = "" ] && { echo "ERROR, not able to find your public IP."; return 0; }

# Start up the WireGuard server
docker-compose up
