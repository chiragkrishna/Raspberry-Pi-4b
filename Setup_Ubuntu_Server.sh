```bash
#############################################################################
#                               Static IP LAN                               #
#############################################################################

#connect using lan first
# view network devices
ls /sys/class/net
# view plans
ls /etc/netplan
# select the correct plan and edit
sudo nano /etc/netplan/10-rpi-ethernet-eth0.yaml

network:
  ethernets:
    eth0:
      # Rename the built-in ethernet device to "eth0"
      match:
        driver: bcmgenet smsc95xx lan78xx
      set-name: eth0
      dhcp4: no
      addresses: [192.168.1.231/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [192.168.1.1]
      optional: true

sudo netplan generate
sudo netplan apply

#############################################################################
#                               Static IP Wifi                              #
#############################################################################

#connect using lan first
# view network devices
ls /sys/class/net
# view plans
ls /etc/netplan
# select the correct plan and edit
sudo nano /etc/netplan/50-cloud-init.yaml

network:
    ethernets:
        eth0:
            dhcp4: true
            optional: true
    version: 2
    wifis:
        wlan0:
            dhcp4: no
            addresses: [192.168.1.233/24]
            gateway4: 192.168.1.1
            nameservers:
              addresses: [192.168.1.1]
            optional: true
            access-points:
                "YOUR-WIFI-NAME":
                    password: "PASSWORD"
                    hidden: true #IF HIDDEN WIFI

# set country code
# https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
# set country code to india
# check if it is set
sudo iw reg get
# if not set
sudo iw reg set IN
# just to make sure add here also
sudo nano /etc/default/crda
REGDOMAIN=IN

sudo netplan generate
sudo netplan apply

#############################################################################
#                               automount mmc                               #
#############################################################################

# check memory card location
sudo fdisk -l
# Locate the UUID
sudo blkid
#add folder and permisions
sudo mkdir /media/mmc
sudo groupadd mmc
sudo usermod -aG mmc $USER
sudo chown -R :mmc /media/mmc
#add at the bottom
sudo nano /etc/fstab
UUID=9691fac2-0a5b-4af8-957b-8ced1ce901c9 /media/mmc    auto nosuid,nodev,nofail,x-gvfs-show 0 0
# test if working
sudo mount -a
sudo reboot

#############################################################################
#							                 Ubuntu basic setup						               	#
#############################################################################

# add user and disable ubuntu
sudo adduser "USER-NAME"
sudo gpasswd -a $USER adm
sudo gpasswd -a $USER sudo

# change the ssh connection to "USER-NAME" and then proceed
sudo passwd -l ubuntu

# set timezones
# to list all the timezones
timedatectl list-timezones

#select your timezone
sudo timedatectl set-timezone Asia/Kolkata

# set hostname
sudo hostnamectl set-hostname "NEW-HOSTNAME"

# disable microcode modules (not required for rpi in ubuntu)
sudo nano /etc/needrestart/needrestart.conf
$nrconf{ucodehints} = 0;
sudo reboot

# update ubuntu
sudo apt update -y && sudo apt upgrade -y
sudo reboot

# install raspi specific contents
sudo apt install linux-modules-extra-raspi libraspberrypi-bin zip unzip net-tools -y
sudo usermod -aG video $USER
sudo reboot

# silience the ssh startup
touch ~/.hushlogin

# enable automatic system updates
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
# enable the following
"${distro_id}:${distro_codename}-updates";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
Unattended-Upgrade::SyslogEnable "true";
Unattended-Upgrade::SyslogFacility "daemon";

# enable custome scripts
# copy all the scripts to home directory first
sudo chmod +x ~/scripts/*
mkdir ~/.temp
touch ~/.temp/temp

# normal user jobs, add at the end
crontab -e 

*/10 * * * * /home/$USER/scripts/./high-cpu-temps.sh >> /dev/null
*/60 * * * * /home/$USER/scripts/./check-other-server.sh >> /dev/null
@reboot sleep 60 && /home/$USER/scripts/./raspi-started.sh >> /dev/null

# sudo jobs, add at the end
sudo crontab -e

0 4 * * 6 /home/$USER/scripts/./backup-server.sh
*/30 * * * * /home/$USER/scripts/./network-troubleshoot.sh >> /dev/null

# limit log files size
sudo journalctl --rotate
sudo journalctl --vacuum-size=100M

# set boot to usb
sudo -E rpi-eeprom-config --edit

BOOT_ORDER=0xf41 # Fall back to SD card IF USB boot fails

or

BOOT_ORDER=0x4 # Boot straight to USB mass storage

#############################################################################
#                               OverClock rpi4                              #
#############################################################################

sudo nano /boot/firmware/config.txt
# add to the end
over_voltage=4
arm_freq=1900

#############################################################################
#							                    	Securing SSH	                        	#
#############################################################################

# secure ssh
mkdir .ssh
# copy ssh pub key
sudo nano ~/.ssh/authorized_keys

#ADD PUB KEY IN THE FILE

sudo nano /etc/ssh/sshd_config

Port "USE-ANY-PORT"
Allowusers $USER
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin prohibit-password

sudo service ssh restart
sudo reboot

#############################################################################
#								                      install docker				         				#
#############################################################################

# docker install
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# give permisions to docker
sudo usermod -aG docker $USER
# reduce logging
sudo nano /etc/docker/daemon.json
# create new file
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3" 
  }
}

#edit for dns settings also used to free port 53 and pihole
sudo nano /etc/systemd/resolved.conf
DNSStubListener=no
sudo sh -c 'rm /etc/resolv.conf && ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf'

sudo systemctl restart systemd-resolved

# remove sudo host not found error
sudo nano /etc/hosts
# add
127.0.0.1 localhost "YOUR-HOSTNAME"

# for use with db's
sudo nano /boot/firmware/cmdline.txt
# edit and add these in the beggining
cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 swapaccount=1
sudo reboot

# check if docker is working
docker run hello-world

#install docker compose (check for newer doker compose version)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
# check if workin
docker-compose --version

# command line completetion
sudo curl \
    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
    -o /etc/bash_completion.d/docker-compose

# install portainer
docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /home/$USER/docker_appdata/portainer/data:/data \
    portainer/portainer-ce:latest
    
# install portainer agent
docker run -d -p 9001:9001 --name portainer_agent --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    portainer/agent:latest

# install watchtower
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /etc/localtime:/etc/localtime:ro \
containrrr/watchtower \
--cleanup \
--remove-volumes \
--include-stopped

# remove plugins which are not required
sudo nano /etc/containerd/config.toml

disabled_plugins = ["cri", "aufs", "btrfs", "devmapper", "zfs"]

#############################################################################
#                               install samba                               #
#############################################################################

sudo apt install samba -y
sudo nano /etc/samba/smb.conf
map to guest = bad user # disable this
usershare allow guests = no

# add at the end of file
[YOUR-FOLDER]
    comment = "YOUR-COMMENTS"
    path = "YOUR-PATH"
    guest ok = no
    read only = no
    browsable = yes
    create mask = 0666
    directory mask = 0755

sudo service smbd restart
sudo smbpasswd -a $USER


#############################################################################
#                               install zsh                                 #
#############################################################################

sudo apt install zsh -y
zsh --version
chsh -s $(which zsh)

#after re-logging check
echo $SHELL

# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install fzf and add pluggins
sudo apt-get install fzf autojump -y

nano ~/.zshrc
# add theme
ZSH_THEME="agnoster"

# add plugins
plugins=(
adb
alias-finder
aliases
autojump
command-not-found
common-aliases
docker
git
history
sudo
ubuntu
zsh-interactive-cd
)

# set aliases
nano ~/.zshrc

alias update='sudo apt update -y && sudo apt upgrade -y'
alias backup='~/scripts/./backup-server.sh'
alias ll='ls -la'
alias remove='sudo rm -r'
alias copy='sudo cp -r'
alias monitor='watch --color "~/scripts/./raspi-monitor.sh --color"'
alias errors='grep "error" /var/log/syslog'
alias fails='grep "fail" /var/log/syslog'
alias logs='cat ~/custome_scripts.log'
alias cron-logs='grep CRON /var/log/syslog'
alias nano='nano -m'
alias zshconf="nano -m ~/.zshrc"

#############################################################################
#                               custome banner                              #
#############################################################################

# install ascii generator
sudo apt install figlet rubygems git -y
#go to home folder
git clone https://github.com/busyloop/lolcat
#install lolcat rainbow colors
cd lolcat/bin && sudo gem install lolcat

#install custom fonts for figlet
cd /usr/share
sudo git clone https://github.com/xero/figlet-fonts
sudo mv figlet-fonts/* figlet
sudo rm -r figlet-fonts

# view all fonts
showfigfonts
# actual demo code (add it at the end of profile)
#zsh = sudo nano /etc/zsh/zshrc
#bash = sudo nano /etc/bash.bashrc
# SAMPLES
figlet -ct -f Poison "U b u n t u" | lolcat -a -d 1 -t
```
