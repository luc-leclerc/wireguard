#!/bin/sh
set -ex;

source ./utility.sh;

# See 776128ea-4a3b-4706-9f2e-9219f15446cb workaround info + script to generate parsing list
LEVEL3_DOCKER_CONTAINER_LISTENING_PORT="${1}"
LEVEL3_PUBLIC_FACING_IP_OR_HOST="${2}"
LEVEL3_PUBLIC_FACING_LISTENING_PORT="${3}"
LEVEL3_VPN_NETWORK="${4}"
LEVEL3_WG_CLIENT_DNS="${5}"
LEVEL3_WG_JSON_CONFIG="${6}"
LEVEL3_WG_MTU="${7}"
LEVEL3_WG_PERSISTENT_KEEPALIVE_SECONDS="${8}"
LEVEL3_WG_PRIVATE_KEY="${9}"
LEVEL3_WIREGUARD_PROCESS_LISTENING_PORT="${10}"
LEVEL3_WORKSPACE_FOLDER="${11}"

set;

startWithExternalConfig() {
  local networkIp="${LEVEL3_VPN_NETWORK%/*}";
  local networkMask="${LEVEL3_VPN_NETWORK##*/}";
  local serverPublicKey=$(echo "$LEVEL3_WG_PRIVATE_KEY" | wg pubkey)

  local networkIpDecimal=$(convert_ipV4_to_decimal "$networkIp");
  local networkGatewayIpDecimal=`expr $networkIpDecimal + 1`;
  local networkGatewayIp="$(convert_decimal_to_ipV4 "$networkGatewayIpDecimal")"

  {
    echo '[Interface]';
    echo "PrivateKey = $LEVEL3_WG_PRIVATE_KEY"
    echo "Address = $networkGatewayIp/$networkMask"
    echo "MTU = $LEVEL3_WG_MTU"
    echo "ListenPort = $LEVEL3_WIREGUARD_PROCESS_LISTENING_PORT"
    echo
  } > /etc/wireguard/wg0.conf

  local clientNames=$(echo $LEVEL3_WG_JSON_CONFIG | jq -r '.client | keys[]');
  for cName in $(echo $LEVEL3_WG_JSON_CONFIG | jq -r '.client | keys[]'); do
    local clientObject=$(echo "$LEVEL3_WG_JSON_CONFIG" | jq -r --arg name "$cName" '.client.[$name]');
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
      echo "DNS = $LEVEL3_WG_CLIENT_DNS"
      echo
      echo "[Peer]"
      echo "PublicKey = $serverPublicKey"
      echo "PresharedKey = $clientPresharedKey"
      echo "PersistentKeepalive = $LEVEL3_WG_PERSISTENT_KEEPALIVE_SECONDS"
      echo "Endpoint = $LEVEL3_PUBLIC_FACING_IP_OR_HOST:$LEVEL3_PUBLIC_FACING_LISTENING_PORT"
      echo "AllowedIPs = 0.0.0.0/0, ::0/0"
    } > "$LEVEL3_WORKSPACE_FOLDER/clients/$cName.conf";
    cat "$LEVEL3_WORKSPACE_FOLDER/clients/$cName.conf" | qrencode --t ansiutf8 > "$LEVEL3_WORKSPACE_FOLDER/clients/$cName-qrcode.txt"
  done

  iptables -t nat \
    -I POSTROUTING \
    -s "$LEVEL3_VPN_NETWORK" \
    -o "eth0" \
    -j MASQUERADE \
    -m comment --comment "wireguard-nat-rule"

  chmod 400 /etc/wireguard/wg0.conf
  wg-quick up /etc/wireguard/wg0.conf

  echo "$(date): Started External Config WireGuard..."
}
startWithExternalConfig
