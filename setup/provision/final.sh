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
The cake is a lie. Site Box 3.5
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

# Allow caching of NFS file share
sudo apt-get install -y cachefilesd
echo "RUN=yes" | sudo tee /etc/default/cachefilesd

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
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES; SET GLOBAL max_connect_errors=10000;"
DEBMAN  = $('sudo grep "password =" /etc/mysql/debian.cnf | cut -d = -f 2 | xargs | cut -d " " -f1')
sudo mysql -u root -e "GRANT ALL PRIVILEGES on *.* TO debian-sys-maint@localhost IDENTIFIED BY PASSWORD '$(DEBMAN)' WITH GRANT OPTION; FLUSH PRIVILEGES;"
sudo service mysql restart
sudo apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
reboot_webserver_helper