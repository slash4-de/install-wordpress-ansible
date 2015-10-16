#!/bin/bash
PATH="/bin:/sbin:/usr/sbin"

iptables -F
iptables -X
iptables -Z
echo {{ ip_forward }} > /proc/sys/net/ipv4/ip_forward
echo "1" > /proc/sys/net/ipv4/ip_dynaddr

iptables -t raw -A PREROUTING -j NOTRACK
iptables -t raw -A OUTPUT -j NOTRACK

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Ping
iptables -A INPUT  -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type echo-reply -j ACCEPT

# DNS:
iptables -A INPUT  -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# Outgoing
{% for service in outgoing %}
{{'##'|e }} {{ service.name }}
{{'##'|e }} {{'=' * service.name|length }}
iptables -A OUTPUT  -p {{ service.protocol | default('tcp') }} {{ '-d '+service.destination if service.destination is defined else '' }} --dport {{ service.port }}  -j ACCEPT
iptables -A INPUT   -p {{ service.protocol | default('tcp') }} {{ '-s '+service.destination if service.destination is defined else '' }} --sport {{ service.port }}  {{ '' if service.protocol is defined and service.protocol == 'udp' else '! --syn ' }} -j ACCEPT
{% endfor %}

# Incoming
{% for service in incoming %}
{{'##'|e }} {{ service.name }}
{{'##'|e }} {{'=' * service.name|length }}
iptables -A INPUT  -p {{ service.protocol | default('tcp') }} {{ '-s '+service.source if service.source is defined else '' }} --dport {{ service.port }}  -j ACCEPT
iptables -A OUTPUT -p {{ service.protocol | default('tcp') }} {{ '-d '+service.source if service.source is defined else '' }} --sport {{ service.port }}  {{ '' if service.protocol is defined and service.protocol == 'udp' else '! --syn ' }} -j ACCEPT
{% endfor %}

# NTP
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A INPUT -p udp --sport 123 -j ACCEPT

# Private Network
{% for host in groups['all_droplets'] %}
iptables -A INPUT  -s {{ hostvars[host]['ansible_eth1']['ipv4']['address']}} -j ACCEPT
iptables -A OUTPUT -d {{ hostvars[host]['ansible_eth1']['ipv4']['address']}} -j ACCEPT
{% endfor %}

# Save active ruleset:
#=====================
/etc/init.d/iptables save active
