#!/usr/bin/env bash
set -Eeuo pipefail

echo "[REDE] Instalando ferramentas de rede e segurança..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  nmap traceroute mtr-tiny dnsutils whois iperf3 tcpdump \
  net-tools ethtool arp-scan socat netcat-openbsd \
  wireshark tshark \
  remmina remmina-plugin-rdp remmina-plugin-vnc \
  openvpn network-manager-openvpn network-manager-openvpn-gnome

if getent group wireshark >/dev/null 2>&1; then
  sudo usermod -aG wireshark "$USER"
fi

echo
echo "[OK] Ferramentas de rede instaladas."
echo "[AVISO] Saia e entre novamente na sessão para aplicar grupos do Wireshark."
