#!/bin/bash
set -e

VPN_IF=$1

if [[ -z "$VPN_IF" ]]; then
    echo "VPN interface not specified. Usage: $0 <interface>"
    exit 1
fi

echo "=====> Cleaning up firewall rules for VPN interface: $VPN_IF"

echo "====>> Removing NAT (MASQUERADE) rule on $VPN_IF"
iptables -t nat -D POSTROUTING -o "$VPN_IF" -j MASQUERADE

echo "====>> Removing Clamping TCP MSS for VPN interface $VPN_IF"
iptables -t mangle -D FORWARD -i "$VPN_IF" -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

echo "====>> Removing rule: Accept established/related incoming connections"
iptables -D INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "====>> Removing rule: Accept new incoming connections not from VPN"
iptables -D INPUT -m conntrack --ctstate NEW ! -i "$VPN_IF" -j ACCEPT

echo "====>> Removing rule: Accept return traffic from VPN clients"
iptables -D INPUT -i "$VPN_IF" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "====>> Removing rule: Drop all other incoming traffic from VPN"
iptables -D INPUT -i "$VPN_IF" -j DROP

echo "====>> Removing rule: Reject forwarding between VPN clients"
iptables -D FORWARD -i "$VPN_IF" -o "$VPN_IF" -j REJECT

echo "====>> Removing rule: Allow VPN to forward traffic to external interfaces (eth+)"
iptables -D FORWARD -i "$VPN_IF" -o eth+ -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

echo "=====> Firewall cleanup completed successfully!"

