# Wireguard

Docker image to run wireguard with externalized configs.

# WIP - Setup looping process to detect IP changes and update DNS entry.

```shell
set +e; # Even on failure it should keeps running

while true
do
  echo 23
  sleep 2s
  # loop infinitely
done
```