#!/bin/bash

arr[0]="Hey Boom! My colleague is back online."
arr[1]="Serve233 is back online."
arr[2]="Server233 is awake, Should I give him a cup of coffee?"
arr[3]="My friend here has woke up!"
arr[4]="I think you need to check on server233, he just woke up now."
arr[5]="Can you check on server233? he is up now."
arr[6]="Server233 is back from the dead."
rand=$(($RANDOM % 7))

value=$(</home/$USER/.temp/temp)
if (("$value" == "true" )); then
	 ping -4 -c4 192.168.1.233 > /dev/null
    if [ $? = 0 ] 
      then
      echo "`date` server233 is back online" >> ~/custome_scripts.log
      echo "" > ~/.temp/temp
      ~/scripts/./telegram-send.sh "${arr[$rand]}"
    fi
fi