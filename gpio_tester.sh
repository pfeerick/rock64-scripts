#!/bin/bash

# Written 2017 Peter Feerick, GPLv3 licensed
#
# Intended for testing Rock64 GPIOs, but should work with
# Raspberry Pi, Pine64, etc, if the GPIO structure is the same.

if [ "$(id -u)" -ne "0" ]; then
        echo "This script requires root to ensure GPIO access."
        exit 1
fi

if [ $# -eq 0 ]; then
    echo "No arguments provided... give me a GPIO export number!"
    exit 1
fi

GPIO_ROOT=/sys/class/gpio

if [ ! -d $GPIO_ROOT/gpio$1 ]; then
   echo "Attempting to set GPIO pin up... "
   echo $1 > $GPIO_ROOT/export
else
   echo -ne "GPIO export already done!"
fi

echo out > $GPIO_ROOT/gpio$1/direction

echo -ne "\nAttempting to toggle GPIO 5 times... "
for  ((i=1; i<= 5; i++)); do
   echo 1 > $GPIO_ROOT/gpio$1/value
   sleep 1
   echo 0 > $GPIO_ROOT/gpio$1/value
   sleep 1
done
echo -ne "\nDone!\n"
