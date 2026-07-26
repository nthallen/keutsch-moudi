#! /bin/bash

echo "Log This is a test command from the GSE" | socat -u stdin UDP4-SENDTO:10.11.96.150:9094
