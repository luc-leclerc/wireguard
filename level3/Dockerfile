FROM alpine:3.19
ARG USER='myuser'
ARG GROUP='mygroup'
ARG LEVEL3_WORKSPACE_FOLDER='/opt/level3'
ENV LEVEL3_WORKSPACE_FOLDER=$LEVEL3_WORKSPACE_FOLDER

RUN apk add wireguard-tools
RUN apk add iptables # To configure network routing
RUN apk add jq # To parse json
RUN apk add libqrencode-tools # To generate QR codes
RUN apk add sudo # To run as non-root user

RUN mkdir -p "$LEVEL3_WORKSPACE_FOLDER/clients"
WORKDIR "$LEVEL3_WORKSPACE_FOLDER"

# Add user & group
RUN addgroup "$GROUP"
RUN adduser -G "$GROUP" -D "$USER"

# Read & exec access
COPY --chmod=500 --chown="$USER:$GROUP" ./src/ .

# Add sudo permissions to run scripts with sudo
RUN echo "$USER ALL=(ALL) NOPASSWD: $LEVEL3_WORKSPACE_FOLDER/start_wireguard.sh" >> /etc/sudoers.d/$USER
RUN echo "$USER ALL=(ALL) NOPASSWD: $LEVEL3_WORKSPACE_FOLDER/auto_destruct.sh" >> /etc/sudoers.d/$USER

USER $USER

CMD [  "/bin/sh", "-c", "./main.sh" ]
