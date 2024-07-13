#!/bin/sh
set -ex;

source ./utility.sh;

startWithExternalConfig() {
  local networkIp="${LEVEL2_VPN_NETWORK%/*}";
  local networkMask="${LEVEL2_VPN_NETWORK##*/}";
  local serverPublicKey=$(echo "$LEVEL2_WG_PRIVATE_KEY" | wg pubkey)

  local networkIpDecimal=$(convert_ipV4_to_decimal "$networkIp");
  local networkGatewayIpDecimal=`expr $networkIpDecimal + 1`;
  local networkGatewayIp="$(convert_decimal_to_ipV4 "$networkGatewayIpDecimal")"

  {
    echo '[Interface]';
    echo "PrivateKey = $LEVEL2_WG_PRIVATE_KEY"
    echo "Address = $networkGatewayIp/$networkMask"
    echo "MTU = $LEVEL2_WG_MTU"
    echo "ListenPort = $LEVEL2_WIREGUARD_PROCESS_LISTENING_PORT"
    echo
  } > /etc/wireguard/wg0.conf

  clientNames=$(echo $LEVEL2_WG_JSON_CONFIG | jq -r '.client | keys[]');
  for cName in $(echo $LEVEL2_WG_JSON_CONFIG | jq -r '.client | keys[]'); do
    local clientObject=$(echo "$LEVEL2_WG_JSON_CONFIG" | jq -r --arg name "$cName" '.client.[$name]');
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

    {
      echo "[Interface]"
      echo "PrivateKey = $clientPrivateKey"
      echo "Address = $clientIpV4/$networkMask"
      echo "DNS = $LEVEL2_WG_CLIENT_DNS"
      echo
      echo "[Peer]"
      echo "PublicKey = $serverPublicKey"
      echo "PresharedKey = $clientPresharedKey"
      echo "PersistentKeepalive = $LEVEL2_WG_PERSISTENT_KEEPALIVE_SECONDS"
      echo "Endpoint = $LEVEL2_PUBLIC_FACING_IP_OR_HOST:$LEVEL2_PUBLIC_FACING_LISTENING_PORT"
      echo "AllowedIPs = 0.0.0.0/0, ::0/0"
    } > "/etc/wireguard/client-$cName.conf";
    cat "/etc/wireguard/client-$cName.conf" | qrencode --t ansiutf8 > "/etc/wireguard/client-$cName-qrcode.txt"
  done

  iptables -t nat \
    -I POSTROUTING \
    -s "$LEVEL2_VPN_NETWORK" \
    -o "eth0" \
    -j MASQUERADE \
    -m comment --comment "wireguard-nat-rule"

  wg-quick up /etc/wireguard/wg0.conf

  echo "Started External Config WireGuard..."
}
startWithExternalConfig

sleep infinity
