#!/bin/bash

arr[0]="hey boom! I'm not able to detect my colleague."
arr[1]="serve233 is offline."
arr[2]="server233 is sleeping, should I kick him?"
arr[3]="my friend here is not waking up!"
arr[4]="I think you need to check on server233."
arr[5]="should i keep checking on server233? he is not responding."
arr[6]="I'm afraid server233 is dead."
rand=$(($RANDOM % 7))
ping -4 -c4 192.168.1.1 > /dev/null
if [ $? != 0 ] 
then
    echo "`date` no network connection, restarting system" >> /home/$USER/custome_scripts.log
    /sbin/ifdown 'wlan0'
    sleep 10
    /sbin/ifup --force 'wlan0'
else
#this is to check if other raspi is down or not
ping -4 -c4 192.168.1.233 > /dev/null
  if [ $? != 0 ] 
    then
      echo "`date` server233 is offline" >> /home/$USER/custome_scripts.log
      echo "true" > /home/$USER/.temp/temp
      /home/$USER/scripts/./telegram-send.sh "${arr[$rand]}"
  fi
fi
