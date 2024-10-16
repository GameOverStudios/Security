#!/bin/bash

pkill dnscrypt-proxy
pkill encrypted-dns
pkill macchange

echo "MastersUniverse" > /etc/hostname

echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
echo "nameserver 127.0.2.1" >> /etc/resolv.conf

./firewall-start

nohup /etc/dnscrypt-proxy/macchange.sh &

nohup encrypted-dns -c /etc/dnscrypt-proxy/encrypted-dns.toml &

nohup /etc/dnscrypt-proxy/dnscrypt-proxy &

tail -f nohup.out 
