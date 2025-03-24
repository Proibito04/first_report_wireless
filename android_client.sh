#!/bin/sh
PORT=$1
IP=$2

echo "Starting listen iperf3 $PORT"
run-as com.termux /data/data/com.termux/files/usr/bin/iperf3 -c $IP -p $PORT 2>&1