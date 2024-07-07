FROM alpine:3.19

RUN apk add wireguard-tools
RUN apk add iptables # To configure network routing
RUN apk add jq # To parse json
RUN apk add libqrencode-tools # To generate QR codes

WORKDIR /etc/wireguard

COPY --chmod=700 main.sh /etc/wireguard/
COPY --chmod=700 start-demo.sh /etc/wireguard/
COPY --chmod=700 start-with-external-config.sh /etc/wireguard/
COPY --chmod=700 utility.sh /etc/wireguard/

CMD [  "/bin/sh", "-c", "/etc/wireguard/main.sh" ]
