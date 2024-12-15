FROM alpine:3.19

RUN apk add wireguard-tools
RUN apk add iptables # To configure network routing
RUN apk add jq # To parse json
RUN apk add libqrencode-tools # To generate QR codes

WORKDIR /etc/wireguard

COPY --chmod=700 ./entrypoint.sh /etc/wireguard/entrypoint.sh

CMD [  "/bin/sh", "-c", "/etc/wireguard/entrypoint.sh" ]
