#!/bin/sh
set -ex;

function startDemo() {
  local serverPrivate=$(wg genkey);
  local serverPublic=$(echo "$serverPrivate" | wg pubkey);
  local clientPrivate=$(wg genkey);
  local clientPublic=$(echo "$clientPrivate" | wg pubkey);
  local preSharedKey=$(wg genpsk);

  {
    echo '[Interface]';
    echo "PrivateKey = $serverPrivate"
    echo "Address = 10.42.130.1/24"
    echo "MTU = $MY_WG_MTU"
    echo "ListenPort = $MY_WG_LISTENING_PORT"
    echo
    echo '[Peer]'
    echo "PublicKey = $clientPublic"
    echo "PresharedKey = $preSharedKey"
    echo "AllowedIPs = 10.42.130.2/32"
    echo
  } > /etc/wireguard/wg0.conf

  {
    echo "[Interface]"
    echo "PrivateKey = $clientPrivate"
    echo "Address = 10.42.130.2/24"
    echo "DNS = 1.1.1.1, 8.8.8.8"
    echo
    echo "[Peer]"
    echo "PublicKey = $serverPublic"
    echo "PresharedKey = $preSharedKey"
    echo "Endpoint = $MY_PUBLIC_FACING_IP_OR_HOST:$MY_PUBLIC_FACING_PORT"
    echo "AllowedIPs = 0.0.0.0/0, ::0/0"
  } | qrencode --t ansiutf8;

  iptables -t nat \
    -I POSTROUTING \
    -s "10.42.130.0/24" \
    -o "eth0" \
    -j MASQUERADE \
    -m comment --comment "wireguard-nat-rule"

  wg-quick up /etc/wireguard/wg0.conf

  echo "Started DEMO WireGuard..."
}

startDemo