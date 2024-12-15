# Demo

Run with less code to ease learning.

# Setup

* Configure your router to redirect UDP traffic from port 44446 to 44444 on the host running wireguard server.
* Run `./start.sj` to start the server, a QR code with sample credential for 1 client.
* Install wireguard on your cellphone, and scan the QR code.

# Potential issues

* This setup hardcode the VPN on network `10.42.130.0/24`, it might conflict with your pre-existing networks.
* This setup hardcode network interface to `eth0`, yours might have a different name.
