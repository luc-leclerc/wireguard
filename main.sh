#!/bin/sh
set -ex;

if [ "$MY_DEMO_SERVER" = "true" ]; then
  /etc/wireguard/start-demo.sh;
else
  /etc/wireguard/start-with-external-config.sh;
fi

sleep infinity;