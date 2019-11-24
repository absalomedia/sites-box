#!/bin/bash

echo "Building VM - MySQL..."
sudo apt-key del 72ECF46A56B4AD39C907BBB71646B01B86E50310
sudo wget -qO - https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | sudo apt-key add -
sudo apt-get -qq update

# /*=============================
# =            MYSQL            =
# =============================*/
echo "Set up MySQL."
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo sed -ie 's/ 127.0.0.1/ 0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -ie '\$ainnodb_use_native_aio=0' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES; SET GLOBAL max_connect_errors=10000;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY 'pC52BiU2Ghq3bnXY';"
sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
if [ ! -f "/etc/mysql/mysql.conf.d/utf8mb4.cnf" ]
then
sudo wget -P /etc/mysql/mysql.conf.d/ https://gist.githubusercontent.com/Xeoncross/2d0503cee10a6374c627f0faaed9ea3f/raw/755f53a68770a31b4b56c14e11e944e9facb10b5/utf8mb4.cnf
fi
sudo service mysql restart
if [ ! -f "/var/www/vhosts/dbbackup.sh" ]
then
sudo wget -P /var/www/vhosts https://raw.githubusercontent.com/absalomedia/sites-box/master/setup/provision/dbbackup.sh
fi
if [ ! -f "/var/www/vhosts/dbrestore.sh" ]
then
sudo wget -P /var/www/vhosts https://raw.githubusercontent.com/absalomedia/sites-box/master/setup/provision/dbrestore.sh
fi
if [ ! -f "/etc/mysql/mysql.conf.d/grant-tables.cnf" ]
then
sudo wget -P /etc/mysql/mysql.conf.d/ https://raw.githubusercontent.com/absalomedia/sites-box/master/setup/provision/grant-tables.cnf
fi
sudo service mysql restart
