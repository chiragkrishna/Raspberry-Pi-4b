#!/bin/bash
arr[0]="I'm up and running."
arr[1]="All systems good."
arr[2]="ahaa!! good to be back, Boom!"
arr[3]="booted successfully."
arr[4]="had a nice long nap."
arr[5]="I'm back."
arr[6]="The power here is horrible!"
rand=$(($RANDOM % 7))
~/scripts/./telegram-send.sh "${arr[$rand]}"