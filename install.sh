#!/bin/bash

echo alias net='/etc/dnscrypt-proxy/start' >> /root/.bashrc
echo alias unet='/etc/dnscrypt-proxy/stop' >> /root/.bashrc

echo alias net='/etc/dnscrypt-proxy/start' >> /home/pop-os/.bashrc
echo alias unet='/etc/dnscrypt-proxy/stop' >> /home/pop-os/.bashrc

echo "nameserver 8.8.8.8" > /etc/resolv.conf
./firewall-start
iptables -L

#apt-get update

apt-get reinstall python3-pip libc-ares2 libdouble-conversion3 libmd4c0 libnetfilter-queue1 libqt5core5a libqt5dbus5 libqt5designer5 libqt5gui5 libqt5help5 libqt5network5 libqt5printsupport5 libqt5sql5 libqt5sql5-sqlite libqt5svg5 libqt5test5 libqt5widgets5 libqt5xml5 libxcb-xinerama0 libxcb-xinput0 python3-grpcio python3-notify2 python3-pyinotify python3-pyqt5 python3-pyqt5.qtsql python3-pyqt5.sip python3-slugify python3-unidecode qt5-gtk-platformtheme qttranslations5-l10n
dpkg -i apps/*.deb

mkdir  ~/.cache
cp pip/ ~/.cache/ -R
pip3 install grpcio==1.44.0

#apt --fix-broken install
#dpkg -i apps/*.deb

systemctl enable opensnitch
systemctl start opensnitch
systemctl status opensnitch

#opensnitch-ui  &
cp unix-tmp-osui-sock/* /etc/opensnitchd/rules/
