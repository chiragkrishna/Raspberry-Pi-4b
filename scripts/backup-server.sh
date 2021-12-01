#!/bin/bash
#check for existing backup and delete it, if present
echo "checking for old backup"
if [ -f "/media/mmc/docker_appdata.zip" ]; then
    echo "detected previous backup"
    echo "updating previous backup"
    sudo zip "/media/mmc/docker_appdata.zip" -FS -r -v -dg -dc -9 docker_appdata
    echo "updating finished..."
    echo "`date` backup finshed" >> /home/$USER/custome_scripts.log
    /home/$USER/scripts/./telegram-send.sh "I finished backing up docker successfully!!"
else
    #backup home dir
    echo "no previous backup detected"
    echo "starting backup"
    sudo zip -r -v -dg -dc -9 "/media/mmc/docker_appdata.zip" docker_appdata
    echo "backup finished..."
    echo "`date` backup finshed" >> /home/$USER/custome_scripts.log
    /home/$USER/scripts/./telegram-send.sh "I finished backing up docker successfully!!"
fi