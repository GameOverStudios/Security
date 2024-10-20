#!/bin/bash

echo "Disable Network Manager"
systemctl disable NetworkManager

echo "Copy Archives"
cp apps/* /var/cache/apt/archives/

echo "Aliases"
echo alias net='/etc/dnscrypt-proxy/start' >> /root/.bashrc
echo alias unet='/etc/dnscrypt-proxy/stop' >> /root/.bashrc

echo "Nameserver 8.8.8.8"
echo "nameserver 8.8.8.8" > /etc/resolv.conf

#iptables -L

#apt-get update
#apt-get reinstall python3-pip libc-ares2 libdouble-conversion3 libmd4c0 libnetfilter-queue1 libqt5core5a libqt5dbus5 libqt5designer5 libqt5gui5 libqt5help5 libqt5network5 libqt5printsupport5 libqt5sql5 libqt5sql5-sqlite libqt5svg5 libqt5test5 libqt5widgets5 libqt5xml5 libxcb-xinerama0 libxcb-xinput0 python3-grpcio python3-notify2 python3-pyinotify python3-pyqt5 python3-pyqt5.qtsql python3-pyqt5.sip python3-slugify python3-unidecode qt5-gtk-platformtheme qttranslations5-l10n

echo "Update System"
sudo apt-get update -y

echo "Install DEBs"
dpkg -i apps/*.deb

echo "Fix Broken Install"
apt --fix-broken install

echo "Python3-PIP"
apt-get install python3-pip

echo "PIP Cache"
mkdir  ~/.cache
cp pip/ ~/.cache/ -R

echo "Install GRCPio"
pip3 install grpcio==1.44.0 qt-material

echo "Firewall Start"
./firewall-start

#apt --fix-broken install
#dpkg -i apps/*.deb

echo "OpenSnitch Rules"
mkdir /etc/opensnitchd
mkdir /etc/opensnitchd/rules
cp FirewallRules/* /etc/opensnitchd/rules/

echo "OpenSnitch Services"
systemctl enable opensnitch
#systemctl start opensnitch
systemctl status opensnitch

rm /etc/opensnitchd/rules
opensnitch-ui  &

