#!/bin/sh
set -ex;

[ "$YOUR_WG_PRIVATE_KEY" = "" -o "$YOUR_WG_JSON_CONFIG" = "" ] && {
  cat <<"EOF"
  # To run the server, you must configure YOUR_WG_PRIVATE_KEY and YOUR_WG_JSON_CONFIG, ex.:

  # Open terminal in docker container, to have access to `wg` executable.
  docker compose run --rm  --entrypoint bash wireguard -c bash

  # Create a server private key
  export YOUR_WG_PRIVATE_KEY=$(wg genkey)

  # Create a client with name 'MyUsername'. Note: To retrieve public key `echo "$privKey" | wg pubkey`
  export YOUR_WG_JSON_CONFIG=$(echo '{ "client": { "MyUsername": { "private": "'"$(wg genkey)"'", "ipv4": "'"10.15.15.25"'", "pre_share" : "'"$(wg genpsk)"'"}}}' | jq -c);
EOF
  return 1;
}

docker-compose up

#export YOUR_WG_PRIVATE_KEY='8JiP/Ahm1bPm1Nd9cAsTB0T8Dnx3Wr1gdnVpsA67X18='
#{"client":{"MyUsername":{"private":"YNgMrPEacUstC5mvJIAVyuBmeLk3mtKP0UEbj42BjmE=","ipv4":"10.15.15.25","pre_share":"wF1YXPksE7sXzUeDvQHz2x+MCikJKVziKUckq8JSujU="}}}
