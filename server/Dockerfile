FROM alpine:3.19
ARG USER='normaluser'
ARG GROUP='normalgroup'

RUN apk add wireguard-tools
RUN apk add iptables # To configure network routing
RUN apk add jq # To parse json
RUN apk add libqrencode-tools # To generate QR codes
RUN apk add sudo # To run as non-root user

RUN mkdir -p "/opt/your_wireguard/clients"
WORKDIR "/opt/your_wireguard"

# Add user & group
RUN addgroup "$GROUP"
RUN adduser -G "$GROUP" -D "$USER"

# Read & exec access
COPY --chmod=500 --chown="$USER:$GROUP" ./src/ .

# Add sudo permissions to run scripts with sudo
RUN echo "$USER ALL=(ALL) NOPASSWD: /opt/your_wireguard/setup.sh" >> /etc/sudoers.d/$USER

USER $USER

CMD [  "/bin/sh", "-c", "./entrypoint.sh" ]
