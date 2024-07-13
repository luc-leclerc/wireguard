FROM alpine:3.19

RUN apk add wireguard-tools
RUN apk add iptables # To configure network routing
RUN apk add jq # To parse json
RUN apk add libqrencode-tools # To generate QR codes

WORKDIR /etc/wireguard

COPY --chmod=700 ./src/ /etc/wireguard/

CMD [  "/bin/sh", "-c", "/etc/wireguard/main.sh" ]
