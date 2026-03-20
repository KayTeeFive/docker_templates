#!/bin/bash
set -e

VPN_IF=$1

if [[ -z "$VPN_IF" ]]; then
    echo "VPN interface not specified. Usage: $0 <interface>"
    exit 1
fi

echo "=====> Setting up firewall rules for VPN interface: $VPN_IF"

echo "====>> Enabling NAT (MASQUERADE) on $VPN_IF"
iptables -t nat -A POSTROUTING -o "$VPN_IF" -j MASQUERADE

echo "====>> Clamping TCP MSS for VPN interface $VPN_IF"
iptables -t mangle -A FORWARD -i "$VPN_IF" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

echo "====>> Allowing established and related incoming connections"
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "====>> Allowing NEW connections not from VPN interface"
iptables -A INPUT -m conntrack --ctstate NEW ! -i "$VPN_IF" -j ACCEPT

echo "====>> Allowing return traffic from VPN clients"
iptables -A INPUT -i "$VPN_IF" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "====>> Dropping all other incoming traffic from VPN interface"
iptables -A INPUT -i "$VPN_IF" -j DROP

echo "====>> Rejecting VPN client-to-client traffic (no forwarding within VPN)"
iptables -A FORWARD -i "$VPN_IF" -o "$VPN_IF" -j REJECT

echo "====>> Allowing VPN clients to forward traffic to external interfaces (eth+)"
iptables -A FORWARD -i "$VPN_IF" -o eth+ -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

echo "=====> Firewall setup complete!"

