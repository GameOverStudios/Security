#!/bin/bash
sudo apt update
echo "INSTALLING MACCHANGER, GIT and Python3-Netifaces" && sleep 1
sudo apt install macchanger python3 python3-pip -y && sudo apt install python3-netifaces || pip3 install netifaces
sudo mv mac.py /usr/local/bin/mac
sudo chmod +x /usr/local/bin/mac
clear -x
echo "INSTALLAZIONE COMPLETATA"
echo "[IT] Scrivi 'sudo mac' nel tuo terminale per cominciare"
echo "[EN] Installatione complete. Write 'sudo mac' on your terminal."
sleep 0.7
echo "Source code: https://github.com/stosempreingiro/MAChange"
