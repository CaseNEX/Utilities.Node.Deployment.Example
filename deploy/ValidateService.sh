#!/bin/bash
sleep 3;
INSTANCES=`pgrep -f 'node /home/www'`;
if [ -z "$INSTANCES" ]; then 
	echo "Failed!"; 
	exit 1;
fi
