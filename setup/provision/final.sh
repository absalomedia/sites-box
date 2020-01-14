#!/bin/bash

WELCOME_MESSAGE='
MMMMMMMMMMMMMNNNmmmmyso++++oossdmmNNMMMMMMMMMMMMMM
yssoo+++oosyyhhhhhhhhhhhdddhhhhhhhhhhhyssooossyhhh
::::::ooo+oosyyyyyyhhhhhdddhhhhhyhyyysoooooo::::::
+:::/::::/++++o/////+++++++////oooo++o+//:::/-:::/
o::/::+osss+/::::::::::::---:-:/::-:/ooo++:::/:--o
y:/:/yydNdhyso/::::::::::::::::::/oyyyhmdhhs/:/:-y
Mh:/yhhMdhyyysso:::::::-:::::::/ssyyyyyhddhhy+::sN
Md:ohsMmhyyyyyyso/:::::-:--:::ooyyyyyyyyhhhhhy/:mM
MN:yhhMhyyyyyyyyss/::::---::/s+/syyyyyyyyyyhhho:NM
MM/yhdhdyyyyyyyyyss/:/:::::/ss//+syyyyyyhyhhdho/MM
MM+shhddyyyyyyyyyyso::/s:-:syss///oyyyys+shhdhooMM
MMs+hyymyyyyyyyyyyys/:/o::+sysss+s+//////yhhhy/sMM
MMh:yhyhyosyyyyyyyhyo::s::syysyyyyo++++oyhhhhs:hMM
MM+/+yhhhhssyyyyhhdho::s:/syyyyyyyyyyyyhhhhhy/:hMM
MM/::shhhddhhyyyhhdhs++y+oyhyyyyyyyyyyhhhhhy+:::NM
MM+::/shddddhyhhyyyys://-:yyyyyyyyyyyhhddhy+::-:MM
MMs:::/ohddddhhyyyys+:/+-:oyyyyyyyyhhdddhy/::::+MM
MMNho:::/yhdhhhhhhyo::/+-::sysyhdhhmdhhyo::::::hMM
MMMMMNhsy++shddhhy+:://o::::oyhmhdddhy+:/o/+ymMMMM
MMMMMMMMMMmh+////:://:/:::/:::/+ooo/oohmMMMMMMMMMM
MMMMMMMMMMMMMmy+://::::----://:::oymMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMy::::::--:::--sdMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMmy+::::::-:oyNMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMmy+:+ymMMMMMMMMMMMMMMMMMMMMMMM
The cake is a lie. Site Box 4.0
'


reboot_webserver_helper() {
    sudo service apache2 restart
    sudo apt -y autoremove
    sudo apt-get -y autoremove
    echo 'Rebooting your webserver'
}

# Add 1GB swap for memory overflow
sudo fallocate -l 1024M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile   none    swap    sw    0   0" | sudo tee -a /etc/fstab
printf "vm.swappiness=10\nvm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Better process management
sudo apt-get install -y htop
sudo apt-get install -y php7.3-dev

# Allow caching of NFS file share
sudo apt-get install -y cachefilesd
echo "RUN=yes" | sudo tee /etc/default/cachefilesd

# Colours on SSH
sudo sed -ie 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
sudo sed -ie 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/vagrant/.bashrc

# /*=======================================
# =            WELCOME MESSAGE            =
# =======================================*/

# Disable default messages by removing execute privilege
sudo chmod -x /etc/update-motd.d/*
sudo updatedb

# Set the new message
echo "$WELCOME_MESSAGE" | sudo tee /etc/motd

# /*===================================================
# =            FINAL GOOD MEASURE, WHY NOT            =
# ===================================================*/
# Grant tables access
if [ ! -f "/etc/mysql/mysql.conf.d/grant-tables.cnf" ]
then
sudo wget -P /etc/mysql/mysql.conf.d/ https://raw.githubusercontent.com/absalomedia/sites-box/master/setup/provision/grant-tables.cnf
fi
sudo service mysql restart
sudo apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
reboot_webserver_helper
