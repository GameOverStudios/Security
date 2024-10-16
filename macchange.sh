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
