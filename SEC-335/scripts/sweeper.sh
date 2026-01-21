#!/bin/bash
for ip in $(seq 2 50); do
	ping -c 1 -W 1 10.0.5.$ip &>/dev/null && echo 10.0.5.$ip >> sweeper1.txt;
done

