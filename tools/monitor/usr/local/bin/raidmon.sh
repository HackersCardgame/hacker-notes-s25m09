#!/bin/bash

green="\e[92m"
yellow="\e[92m"
white="\e[92m"
red="\e[91m"
default="\e[0m"


exec > /dev/tty7 2>&1

while true
do
	stamp=$(date)
        disks=$(mdadm --detail /dev/md65 |grep State -A6 --color)
        disks2=$(mdadm --detail /dev/md12|grep State -A6 --color)
	frei=$(df -h |grep -v tmpfs )
	frei2=$(df |grep -v tmpfs )
	for i in $(seq 1 60)
	do
		clear

		echo '---=== [ RAID stat ] ===---'
	        echo ' ------------------------- '
		echo	
		echo -e "${green}$(date)${default}"
		echo	
	        echo ' ------------------------- '
		echo	
		stats=$(cat /proc/mdstat)
		echo -e "${green}  $stats ${default}"
		echo
		echo '  ---=== [ disks ] ===---'
	        echo ' ------------------------- '
		echo	
		echo	
		mount |grep -e media -e "dev/sd" --color
		echo	
		echo	
		echo -e "${red}$stamp${default}"
		echo
		echo
		echo -e "$frei"
		echo
		echo
		echo -e "$disks"
		echo -e "$disks2"
		echo
		cat /proc/meminfo  |grep Dirt --color
		echo
		awk '{if ($3 ~ /md/) print $3 " RX: ", $6 / 1024 / 1024 / 1024 * 512, " GB  TX: ", $10 / 1024 / 1024 / 1024 * 512 }' /proc/diskstats 
		echo
		awk '{if ($3 ~ /sd[a-z]$/) print $3 " RX: ", $6 / 1024 / 1024 / 1024 * 512, " GB  TX: ", $10 / 1024 / 1024 / 1024 * 512 }' /proc/diskstats 
		echo
		awk '{if ($1 ~ /en,*/) print $1 "RX: ", $2 / 1024 / 1024 " MB  TX: ", $10 / 1024 / 1024, "MB "  }' /proc/net/dev

		sleep 2
		
		clear
		echo '---=== [ RAID stat ] ===---'
	        echo ' ------------------------- '
		echo	
		echo -e "${red}$(date)${default}"
		echo	
	        echo ' ------------------------- '
		echo	
		stats=$(cat /proc/mdstat)
		echo -e "${red}  $stats ${default}"
		echo
		echo '  ---=== [ disks ] ===---'
	        echo ' ------------------------- '
		echo	
		echo	
		mount |grep -e media -e "dev/sd" --color
		echo	
		echo	
		echo -e "${red}$stamp${default}"
		echo
		echo
		echo -e "$frei"
		echo
		echo
		echo -e "$disks"
		echo 
		cat /proc/meminfo  |grep Dirt --color
		echo
		awk '{if ($3 ~ /md/) print $3 " RX: ", $6 / 1024 / 1024 / 1024 * 512, " GB  TX: ", $10 / 1024 / 1024 / 1024 * 512 }' /proc/diskstats 
		echo
		awk '{if ($3 ~ /sd[a-z]$/) print $3 " RX: ", $6 / 1024 / 1024 / 1024 * 512, " GB  TX: ", $10 / 1024 / 1024 / 1024 * 512 }' /proc/diskstats
		echo

		awk '{if ($1 ~ /en,*/) print $1 "RX: ", $2 / 1024 / 1024 " MB  TX: ", $10 / 1024 / 1024, "MB "  }' /proc/net/dev
		sleep 2
		
	done

done

