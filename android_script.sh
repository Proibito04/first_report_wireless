#!/bin/sh
PORT=$1

echo "Starting iperf3 in port $PORT"
run-as com.termux /data/data/com.termux/files/usr/bin/iperf3 -s -p $PORT -1 2>&1

