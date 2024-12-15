#!/bin/sh
set -e;

source ./utility.sh;

YOUR_PUBLIC_HOSTNAME=$(wget -qO- 'https://checkip.amazonaws.com');
YOUR_PUBLIC_PORT=$(echo "$1" | jq -r '.YOUR_PUBLIC_PORT');

YOUR_VPN_NETWORK=$(echo "$1" | jq -r '.YOUR_VPN_NETWORK');

YOUR_WG_PRIVATE_KEY=$(echo "$1" | jq -r '.YOUR_WG_PRIVATE_KEY');
YOUR_WG_JSON_CONFIG=$(echo "$1" | jq -r '.YOUR_WG_JSON_CONFIG');
YOUR_WG_CLIENT_DNS=$(echo "$1" | jq -r '.YOUR_WG_CLIENT_DNS');
YOUR_WG_PERSISTENT_KEEPALIVE_SECONDS=$(echo "$1" | jq -r '.YOUR_WG_PERSISTENT_KEEPALIVE_SECONDS');

networkIp="${YOUR_VPN_NETWORK%/*}";
networkMask="${YOUR_VPN_NETWORK##*/}";
serverPublicKey=$(echo "$YOUR_WG_PRIVATE_KEY" | wg pubkey)

networkIpDecimal=$(convert_ipV4_to_decimal "$networkIp");
networkGatewayIpDecimal=`expr $networkIpDecimal + 1`;
networkGatewayIp="$(convert_decimal_to_ipV4 "$networkGatewayIpDecimal")"

{
  echo '[Interface]';
  echo "PrivateKey = $YOUR_WG_PRIVATE_KEY"
  echo "Address = $networkGatewayIp/$networkMask"
  echo "MTU = $YOUR_WG_MTU"
  echo "ListenPort = 51111"
  echo
} > /etc/wireguard/wg0.conf

clientNames=$(echo $YOUR_WG_JSON_CONFIG | jq -r '.client | keys[]');
for cName in $(echo $YOUR_WG_JSON_CONFIG | jq -r '.client | keys[]'); do
  clientObject=$(echo "$YOUR_WG_JSON_CONFIG" | jq -r --arg name "$cName" '.client.[$name]');
  clientPrivateKey=$(echo "$clientObject" | jq -r '.private');
  clientPublicKey=$(echo "$clientPrivateKey" | wg pubkey);
  clientPresharedKey=$(echo "$clientObject" | jq -r '.pre_share');
  clientIpV4=$(echo "$clientObject" | jq -r '.ipv4');

  {
    echo "### begin ${cName} ###"
    echo '[Peer]'
    echo "PublicKey = $clientPublicKey"
    echo "PresharedKey = $clientPresharedKey"
    echo "AllowedIPs = $clientIpV4/32"
    echo "### end ${cName} ###"
  } >> /etc/wireguard/wg0.conf

  {
    echo "[Interface]"
    echo "PrivateKey = $clientPrivateKey"
    echo "Address = $clientIpV4/$networkMask"
    echo "DNS = $YOUR_WG_CLIENT_DNS"
    echo
    echo "[Peer]"
    echo "PublicKey = $serverPublicKey"
    echo "PresharedKey = $clientPresharedKey"
    echo "PersistentKeepalive = $YOUR_WG_PERSISTENT_KEEPALIVE_SECONDS"
    echo "Endpoint = $YOUR_PUBLIC_HOSTNAME:$YOUR_PUBLIC_PORT"
    echo "AllowedIPs = 0.0.0.0/0, ::0/0"
  } > "/opt/your_wireguard/clients/$cName.conf";
  cat "/opt/your_wireguard/clients/$cName.conf" | qrencode --t ansiutf8 > "/opt/your_wireguard/clients/$cName-qrcode.txt"
done

iptables -t nat \
  -I POSTROUTING \
  -s "$YOUR_VPN_NETWORK" \
  -o "eth0" \
  -j MASQUERADE \
  -m comment --comment "wireguard-nat-rule"

chmod 400 /etc/wireguard/wg0.conf
wg-quick up /etc/wireguard/wg0.conf

echo "$(date): Started wireGuard..."
