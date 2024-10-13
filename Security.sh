    GREEN='\033[0;32m'
    NC='\033[0m'

    printf " ${GREEN}\n"${NC}
    printf " ${GREEN}[  ...:::|-| Firewall ] |-|:::... ]\n"${NC}
    printf " ${GREEN}\n"${NC}

    echo "MastersUniverse" > /etc/hostname
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 127.0.0.1" >> /etc/resolv.conf
    echo "nameserver 127.0.2.1" >> /etc/resolv.conf
    
    printf " ${GREEN}[+] Clean Old Versions\n"${NC}
    sudo rm /etc/systemd/system/macchange.service 
    sudo rm /etc/systemd/system/multi-user.target.wants/dnscrypt-proxy*
    sudo rm /etc/firewall-start
    sudo rm /etc/macchange
    sudo rm /etc/dnscrypt-proxy -R

    # -----------------------------------------------------------------------------------------------------------------------

    printf " ${GREEN}[+] Create Directory\n"${NC}
    mkdir /etc/dnscrypt-proxy/
    echo ""
    
    printf " ${GREEN}[+] Downloading Public-Resolvers...\n"${NC}
    wget https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md -O /etc/dnscrypt-proxy/public-resolvers.md
    
    printf " ${GREEN}[+] Downloading Relays...\n"${NC}
    wget https://download.dnscrypt.info/resolvers-list/v3/relays.md -O /etc/dnscrypt-proxy/relays.md
    
    printf " ${GREEN}[+] Downloading ODOH Servers...\n"${NC}
    wget https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md -O /etc/dnscrypt-proxy/odoh-servers.md 
    
    printf " ${GREEN}[+] Downloading ODOH Relays...\n"${NC}
    wget https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md -O /etc/dnscrypt-proxy/odoh-relays.md 
    
    printf " ${GREEN}[+] Downloading IPTables Rules...\n"${NC}
    wget https://gist.githubusercontent.com/GameOverStudios/169472ae5a1e64ad14fa8714d01b3a49/raw/28a90527bc49f14c39e0f13dbc2fd088e96a169e/iptables-medium.sh -O /etc/firewall-start
    
    printf " ${GREEN}[+] Downloading DNSCrypt...\n"${NC}
    wget https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.5/dnscrypt-proxy-linux_x86_64-2.1.5.tar.gz
    
    printf " ${GREEN}[+] Downloading ADBlockers...\n"${NC}
    wget https://gist.githubusercontent.com/GameOverStudios/8e2a16dbf62902a8094943c5d0c8dc82/raw/update-adblocker.sh -O /etc/dnscrypt-proxy/update-adblocker.sh
    echo ""

    printf " ${GREEN}[+] Downloading Encrypted DNS Server...\n"${NC}
    wget https://github.com/DNSCrypt/encrypted-dns-server/releases/download/0.9.16/encrypted-dns_0.9.16_amd64.deb
    wget https://raw.githubusercontent.com/DNSCrypt/encrypted-dns-server/refs/heads/master/example-encrypted-dns.toml -O /etc/dnscrypt-proxy/encrypted-dns.toml
    sudo dpkg -i encrypted-dns_0.9.16_amd64.deb
    echo ""

    tar -xzvf dnscrypt-proxy-linux_x86_64-2.1.5.tar.gz
    cp linux-x86_64/* /etc/dnscrypt-proxy/
    cp linux-x86_64/example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    cd /etc/dnscrypt-proxy/

    # -----------------------------------------------------------------------------------------------------------------------
    
    printf " ${GREEN}[+] Getting ADBlockers...\n"${NC}
    chmod +x update-adblocker.sh
    ./update-adblocker.sh
    echo ""

    # -----------------------------------------------------------------------------------------------------------------------

    printf " ${GREEN}[+] Creating Service Firewall...\n"${NC}
    cat <<EOF > /etc/systemd/system/firewall.service
    [Unit]
    Description=IpTables Firewall
    Before=network.target

    [Service]
    Type=simple
    ExecStart=/bin/bash /etc/firewall-start
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
EOF
    chmod 755 /etc/systemd/system/firewall.service
    echo ""

    printf " ${GREEN}[+] Starting Firewall...\n"${NC}
    chmod +x /etc/firewall-start
    systemctl enable firewall
    systemctl start firewall
    systemctl status firewall
    iptables --list
    /etc/./firewall-start

# -----------------------------------------------------------------------------------------------------------------------

    printf " ${GREEN}[+] Creating MacChanger Address...\n"${NC}
    apt-get install -y macchange
    cat <<EOF > /etc/macchange
    #!/bin/bash -x

    while true; do
    sleep 10

    if ifconfig wlo1 | grep "inet" > /dev/null; then
        echo "connected via wlo1"
    elif ifconfig eth0 | grep "inet" > /dev/null; then
        echo "connected via eth0"
    else
        echo "not connected, macchange in effect"

        # Turns off the interfaces so we can do some macchange magic
        ifconfig eth0 down
        ifconfig wlo1 down

        # Changes the MAC address on eth0 to a random one
        macchanger -r eth0
        ifconfig eth0 up

        # Changes the MAC address on wlo1 to a random one
        macchanger -r wlo1
        ifconfig wlo1 up

        # Waits 50 seconds before the next iteration
        sleep 50
    fi
    done
EOF
    chmod +x /etc/macchange

    cat <<EOF > /etc/systemd/system/macchange.service
    [Unit]
    Description=Script para verificar a conexão de rede e trocar o MAC address
    Before=network.target

    [Service]
    ExecStart=/bin/bash /etc/macchange
    Restart=always
    RemainAfterExit=yes
    User=root

    [Install]
    WantedBy=multi-user.target
EOF
    systemctl enable macchange
    systemctl start macchange
    systemctl status macchange

# -----------------------------------------------------------------------------------------------------------------------

    printf " ${GREEN}\n"${NC}
    printf " ${GREEN}[ ...:::|-| DNS Crypt Proxy ] |-|:::...\n"${NC}
    printf " ${GREEN}\n"${NC}

    printf " ${GREEN}[+] Decompress DNSCrypt\n"${NC}
    
    sudo sed -i \
        -e 's/dnscrypt_servers = true/dnscrypt_servers = false/' \
        -e 's/odoh_servers = false/odoh_servers = true/' \
        -e 's/require_dnssec = false/require_dnssec = true/' \
        -e "s/netprobe_address = '9.9.9.9:53'/netprobe_address = '8.8.8.8:53'/" \
        -e 's/block_ipv6 = false/block_ipv6 = true/' \
        -e 's/# blocked_names_file =/blocked_names_file =/' \
        -e 's/blocked-names.txt/blocked_names.txt/' \
        -e 's/force_tcp = false/force_tcp = true/' \
        /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    echo ""

    sudo sed -i \
        -e 's/9.9.9.9:53/8.8.8.8:53/' \
        /etc/dnscrypt-proxy/encrypted-dns.toml

    printf " ${GREEN}[+] Starting DNSCrypt....\n"${NC}
    sudo ./dnscrypt-proxy -service install
    #sudo systemctl enable dnscrypt-proxy
    #sudo systemctl start dnscrypt-proxy
    #sudo systemctl status dnscrypt-proxy

    printf " ${GREEN}[+] Verify DNS Service\n"${NC}
    ./dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -resolve google.com
    #nmtui

    printf " ${GREEN}[+] Tor Service\n"${NC}
    sudo apt install tor torsocks -y
    sudo syatemctl enable tor
    sudo systemctl start tor
    sudo systemctl status tor

    printf " ${GREEN}[+] Create Executable\n"${NC}
    echo 'echo "MastersUniverse" > /etc/hostname' >> /etc/dnscrypt-proxy/start.sh
    echo 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf' >> /etc/dnscrypt-proxy/start.sh
    echo 'echo "nameserver 127.0.0.1" >> /etc/resolv.conf' >> /etc/dnscrypt-proxy/start.sh
    echo 'echo "nameserver 127.0.2.1" >> /etc/resolv.conf' >> /etc/dnscrypt-proxy/start.sh
    echo "nohup /etc/macchange &" >> /etc/dnscrypt-proxy/start.sh
    echo "nohup /etc/dnscrypt-proxy/dnscrypt-proxy &" >> /etc/dnscrypt-proxy/start.sh
    echo "nohup encrypted-dns -c /etc/dnscrypt-proxy/encrypted-dns.toml &" >> /etc/dnscrypt-proxy/start.sh
    chmod +x /etc/dnscrypt-proxy/start.sh
    
    printf " ${GREEN}[+] DNS Stamp\n"${NC}
    encrypted-dns -c /etc/dnscrypt-proxy/encrypted-dns.toml
    echo "DNS Stamp:"
    read dns_stamp

    -e 's/# [static.myserver]/[static.myserver]/' \
        -e '/stamp = 'sdns://AQcAAAAAAAAAAAAQMi5kbnNjcnlwdC1jZXJ0Lg/stamp = '$stamp/' \
        /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    
    echo ""
    printf " ${GREEN}[+] \nOpenSnitch
                + 127.0.0.1:53 (udp) \n
                google-chrome 80, 443
                dnscrypt-proxy 9050, 443 (tcp, udp)
                retirar 8.8.8.8 firewall
    "${NC}
    echo ""

    printf " ${GREEN}[+] Start\n"${NC}
    /etc/dnscrypt-proxy/./start