#!/bin/bash

echo "Building VM - MySQL..."
sudo apt purge -y php7.1*
sudo apt purge -y php7.0*
sudo apt purge -y php5.6*
sudo systemctl stop postgresql
sudo apt purge -y postgresql-9.5* 
sudo apt purge -y golang-1.8*
sudo apt-key del 72ECF46A56B4AD39C907BBB71646B01B86E50310
sudo wget -qO - https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | sudo apt-key add -
sudo apt-get -qq update

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
if [ ! -f "/etc/mysql/mysql.conf.d/utf8mb4.cnf" ]
then
sudo wget -P /etc/mysql/mysql.conf.d/ https://gist.githubusercontent.com/Xeoncross/2d0503cee10a6374c627f0faaed9ea3f/raw/755f53a68770a31b4b56c14e11e944e9facb10b5/utf8mb4.cnf
fi
service mysql restart