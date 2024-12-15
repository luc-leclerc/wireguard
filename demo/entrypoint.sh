#!/bin/sh
set -ex;

YOUR_PUBLIC_HOSTNAME=$(wget -qO- 'https://checkip.amazonaws.com');

serverPrivate=$(wg genkey);
serverPublic=$(echo "$serverPrivate" | wg pubkey);
clientPrivate=$(wg genkey);
clientPublic=$(echo "$clientPrivate" | wg pubkey);
preSharedKey=$(wg genpsk);

{
  echo '[Interface]';
  echo "PrivateKey = $serverPrivate"
  echo "Address = 10.42.130.1/24"
  echo "MTU = 1420"
  echo "ListenPort = 51111"
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
  echo "DNS = 1.1.1.1, 8.8.8.8" # Cloudflare as primary DNS, Google as secondary DNS
  echo
  echo "[Peer]"
  echo "PublicKey = $serverPublic"
  echo "PresharedKey = $preSharedKey"
  echo "PersistentKeepalive = 25" # Optional config, should help with long-lived TCP connection with hardly any data flowing
  echo "Endpoint = $YOUR_PUBLIC_HOSTNAME:44446"
  # Value '0.0.0.0/0, ::0/0' will ensure that all traffic goes through our tunnel; this can be changed so only traffic for internal resources will use VPN.
  echo "AllowedIPs = 0.0.0.0/0, ::0/0"
} > "/etc/wireguard/client.conf";
cat "/etc/wireguard/client.conf" | qrencode --t ansiutf8 > "/etc/wireguard/client-qrcode.txt";
cat "/etc/wireguard/client-qrcode.txt";

iptables -t nat \
  -I POSTROUTING \
  -s "10.42.130.0/24" \
  -o "eth0" \
  -j MASQUERADE \
  -m comment --comment "wireguard-nat-rule"

wg-quick up /etc/wireguard/wg0.conf

echo "Started DEMO WireGuard..."

sleep infinity
