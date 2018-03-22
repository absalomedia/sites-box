#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# /*=================================
# =            VARIABLES            =
# =================================*/
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


echo "Starting VM..."
sudo apt-get -qq update

sudo apt purge -y php7.1*
sudo apt purge -y php7.0*
sudo apt purge -y php5.6*
#sudo apt purge -y mysql*
sudo systemctl stop postgresql
sudo apt purge -y postgresql-9.5* 
#sudo apt purge -y golang-1.8*

# /*=============================
# =            MYSQL            =
# =============================*/
echo "Set up MySQL."
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo rm /var/lib/mysql/*
sudo apt-get install mysql-server
sudo mysqld  --initialize-insecure 
sudo sed -ie 's/ 127.0.0.1/ 0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES; SET GLOBAL max_connect_errors=10000;"
sudo wget -P /etc/mysql/mysql.conf.d/ https://gist.githubusercontent.com/Xeoncross/2d0503cee10a6374c627f0faaed9ea3f/raw/755f53a68770a31b4b56c14e11e944e9facb10b5/utf8mb4.cnf
sudo mysqladmin -uroot create scotchbox
service mysql restart
reboot_webserver_helper

sudo apt-get install -y build-essential
sudo apt-get install -y tcl
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo apt-get -y install vim
sudo apt-get -y install dnsmasq
sudo apt-get -y install locate
sudo apt-get -y install git

# Weird Vagrant issue fix
sudo apt-get install -y ifupdown


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
sudo apt-get -qq update
sudo apt-get -y upgrade
reboot_webserver_helper

# /*====================================
# =            YOU ARE DONE            =
# ====================================*/
echo 'Booooooooom! We are done. You are a hero. I love you.'