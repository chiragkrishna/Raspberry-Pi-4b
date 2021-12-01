#!/bin/bash
#check for existing backup and delete it, if present
echo "checking for docker_appdata"
if [ -d "/home/$USER/docker_appdata" ]; then
    echo "removing docker_appdata"
    sudo rm -r "/home/$USER/docker_appdata"
    echo "restoring backup"
    sudo unzip "/media/mmc/docker_appdata.zip" -d /home/$USER/docker_appdata
    echo "restoring finished"
else
    #restore home dir
    echo "restoring backup"
    sudo unzip "/media/mmc/docker_appdata.zip" -d /home/$USER/docker_appdata
    echo "restoring finished"
fi