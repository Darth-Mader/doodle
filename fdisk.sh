#!/usr/bin/env bash

function commit {
	fdisk $DEVICE < /tmp/fdisk.script
}

function add {
	echo "Would you like to add a partition? [y/n]"
	read ADD
	if  [ ! "$ADD" = "Y" -a ! "$ADD" = "y" ] ; then
		echo -e "n\n\n\n\n" >> /tmp/fdisk.script
	fi
}

function delete {
	echo "Would you like to delete a partition? [y/n]"
	read DELETE
	while [ ! "$DELETE" = "N" -a ! "$DELETE" = "n" ] ; do
		if  [ ! "$DELETE" = "Y" -a ! "$DELETE" = "y" ] ; then
			echo "Invalid input... enter y/n"
			read DELETE
		else 
			echo "Which partition would you like to delete? [number... get it wrong and I fuck you up boi]"
			read DEL_PART
			echo -e "d" >> /tmp/fdisk.script
			echo -e "$DEL_PART\n" >> /tmp/fdisk.script
			echo "Would you like to delete another partition? [y/n]"
			read DELETE
		fi
	done
}

function format {
	echo "Would you like to format the device? [Y/n]"
	read FORMAT
	if [ $FORMAT -o "$FORMAT" = "Y" -o "$FORMAT" = "y" ] ; then
		echo -e "g\n" >> /tmp/fdisk.script
	elif [ "$FORMAT" = "N" -o "$FORMAT" = "n" ] ; then
		break
	else 
		echo "Invalid input"
		format
	fi
}

function configure {
	echo -e "\n" > /tmp/fdisk.script
	echo "What would you like to do with the device?"
	format
	sleep 3
	if [ "$FORMAT" = "N" -o "$FORMAT" = "n" ] ; then
		delete
		sleep 3
	fi
	add
	sleep 3
	echo -e "w\n" > /tmp/fdisk.script
}

function device_info {
	echo -e "\nHere's the device's info:"
	fdisk -l $DEVICE | grep "Disklabel type"
	fdisk -l /dev/sdc | tac | while read line ; do
		if echo $line | grep -q ^Device ; then 
			break 
		else echo $line 
		fi
	done
	echo ""
}

function get_DEVICE {
	echo "What device would you want to edit?"
	read DEVICE
	if [ -e $DEVICE ] ; then
		echo "Great! $DEVICE will be configured"
	elif [ -e /dev/$DEVICE ] ; then 
		DEVICE="/dev/$DEVICE"
		echo "Great! $DEVICE will be configured"
	else 
		echo "Problem with finding the device... Try again"
		get_DEVICE
	fi
}


get_DEVICE
sleep 3 
device_info
sleep 3
configure
commit
sleep 3
echo "What's new?"
device_info

