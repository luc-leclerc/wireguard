#!/bin/sh
set -ex;

source ./utility.sh;

startWithExternalConfig() {
  local networkIp="${MY_VPN_NETWORK%/*}"; # The '10.15.15.0' in '10.15.15.0/24'
  local networkMask="${MY_VPN_NETWORK##*/}"; # The '24' in '10.15.15.0/24'
  local serverPublicKey=$(echo "$MY_WG_PRIVATE_KEY" | wg pubkey)

  local networkIpDecimal=$(convert_ipV4_to_decimal "$networkIp");
  local networkGatewayIpDecimal=`expr $networkIpDecimal + 1`;
  local networkGatewayIp="$(convert_decimal_to_ipV4 "$networkGatewayIpDecimal")"

  # First part of server configs
  {
    echo '[Interface]';
    echo "PrivateKey = $MY_WG_PRIVATE_KEY"
    echo "Address = $networkGatewayIp/$networkMask"
    echo "MTU = $MY_WG_MTU"
    echo "ListenPort = $MY_WG_LISTENING_PORT"
    echo
  } > /etc/wireguard/wg0.conf

  clientNames=$(echo $MY_WG_JSON_CONFIG | jq -r '.client | keys[]');
  for cName in $(echo $MY_WG_JSON_CONFIG | jq -r '.client | keys[]'); do
    local clientObject=$(echo "$MY_WG_JSON_CONFIG" | jq -r --arg name "$cName" '.client.[$name]');
    local clientPrivateKey=$(echo "$clientObject" | jq -r '.private');
    local clientPublicKey=$(echo "$clientPrivateKey" | wg pubkey);
    local clientPresharedKey=$(echo "$clientObject" | jq -r '.pre_share');
    local clientIpV4=$(echo "$clientObject" | jq -r '.ipv4');

    {
      echo "### begin ${cName} ###"
      echo '[Peer]'
      echo "PublicKey = $clientPublicKey"
      echo "PresharedKey = $clientPresharedKey"
      echo "AllowedIPs = $clientIpV4/32"
      echo "### end ${cName} ###"
    } >> /etc/wireguard/wg0.conf

    # Generate QR code
    {
      echo "[Interface]"
      echo "PrivateKey = $clientPrivateKey"
      echo "Address = $clientIpV4/$networkMask"
      echo "DNS = $MY_WG_CLIENT_DNS"
      echo
      echo "[Peer]"
      echo "PublicKey = $serverPublicKey"
      echo "PresharedKey = $clientPresharedKey"
      echo "PersistentKeepalive = $MY_WG_PERSISTENT_KEEPALIVE_SECONDS"
      echo "Endpoint = $MY_PUBLIC_FACING_IP_OR_HOST:$MY_PUBLIC_FACING_PORT"
      echo "AllowedIPs = 0.0.0.0/0, ::0/0"
    } > "/etc/wireguard/client-$cName.conf";
    cat "/etc/wireguard/client-$cName.conf" | qrencode --t ansiutf8 > "/etc/wireguard/client-$cName-qrcode.txt"
  done

  iptables -t nat \
    -I POSTROUTING \
    -s "$MY_VPN_NETWORK" \
    -o "eth0" \
    -j MASQUERADE \
    -m comment --comment "wireguard-nat-rule"

  wg-quick up /etc/wireguard/wg0.conf

  echo "Started External Config WireGuard..."
}
startWithExternalConfig
