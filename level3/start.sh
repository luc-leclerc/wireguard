#!/bin/sh
set -ex;

export LEVEL3_PUBLIC_FACING_IP_OR_HOST=$(curl --max-time 1 -s 'https://checkip.amazonaws.com' 2>/dev/null || echo "")
[ "$LEVEL3_PUBLIC_FACING_IP_OR_HOST" = "" ] && { echo "ERROR, not able to find your public IP."; return 0; }

[ "$LEVEL3_WG_JSON_CONFIG" = "" ] && { echo "ERROR, missing client configs."; return 0; }
[ "$LEVEL3_WG_PRIVATE_KEY" = "" ] && { echo "ERROR, missing server private key."; return 0; }

docker-compose up
