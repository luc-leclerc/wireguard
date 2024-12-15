#!/bin/sh

jsonConfig="{}";
jsonConfig=$(echo $jsonConfig | jq '. += { "YOUR_WG_PRIVATE_KEY": "'"$YOUR_WG_PRIVATE_KEY"'"}')
jsonConfig=$(echo $jsonConfig | jq --arg myVal "$YOUR_WG_JSON_CONFIG" '. += { "YOUR_WG_JSON_CONFIG": $myVal}')
jsonConfig=$(echo $jsonConfig | jq '. += { "YOUR_PUBLIC_PORT": "44446"}')

jsonConfig=$(echo $jsonConfig | jq '. += { "YOUR_VPN_NETWORK": "10.15.15.0/24"}')
jsonConfig=$(echo $jsonConfig | jq '. += { "YOUR_WG_MTU": "1420"}')
jsonConfig=$(echo $jsonConfig | jq '. += { "YOUR_WG_CLIENT_DNS": "1.1.1.1, 8.8.8.8"}')
jsonConfig=$(echo $jsonConfig | jq '. += { "YOUR_WG_PERSISTENT_KEEPALIVE_SECONDS": "25"}')

# Configure wireguard
sudo ./setup.sh "$jsonConfig"



# Delete unneeded files
#{ sleep 1s; rm -rf /; } &

sleep infinity