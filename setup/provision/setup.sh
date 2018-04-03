#!/bin/bash

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
sudo systemctl stop postgresql
sudo apt purge -y postgresql-9.5* 
sudo apt purge -y golang-1.8*
sudo apt-key del 72ECF46A56B4AD39C907BBB71646B01B86E50310
sudo wget -qO - https://raw.githubusercontent.com/yarnpkg/releases/gh-pages/debian/pubkey.gpg | sudo apt-key add -


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
reboot_webserver_helper

sudo apt-get install -y build-essential
sudo apt-get install -y tcl
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo apt-get -y install vim
sudo apt-get -y install dnsmasq
sudo apt-get -y install locate
sudo apt-get -y install git
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Weird Vagrant issue fix
sudo apt-get install -y ifupdown

echo "Updating Apache..."
sudo add-apt-repository -y ppa:ondrej/apache2 # Super Latest Version
sudo apt-get -qq update
sudo apt-get -y install apache2

sudo a2enmod expires
sudo a2enmod headers
sudo a2enmod include
sudo a2enmod rewrite
sudo a2enmod ssl

reboot_webserver_helper

echo "Updating PHP"
sudo add-apt-repository -y ppa:ondrej/php # Super Latest Version (currently 7.2)
sudo apt-get -qq update

$pkg='php7.2'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
sudo apt-get install -y php7.2
sudo apt-get -y install libapache2-mod-php

    # Add index.php to readable file types
    MAKE_PHP_PRIORITY='<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
    </IfModule>'
    echo "$MAKE_PHP_PRIORITY" | sudo tee /etc/apache2/mods-enabled/dir.conf

reboot_webserver_helper

sudo apt-get -y install php7.2-common
sudo apt-get -y install php7.2-dev

# Common Useful Stuff (some of these are probably already installed)
sudo apt-get -y install php7.2-bcmath
sudo apt-get -y install php7.2-bz2
sudo apt-get -y install php7.2-cgi
sudo apt-get -y install php7.2-cli
sudo apt-get -y install php7.2-fpm
sudo apt-get -y install php7.2-gd
sudo apt-get -y install php7.2-imap
sudo apt-get -y install php7.2-intl
sudo apt-get -y install php7.2-json
sudo apt-get -y install php7.2-mbstring
sudo apt-get -y install php7.2-odbc
sudo apt-get -y install php-pear
sudo apt-get -y install php7.2-pspell
sudo apt-get -y install php7.2-tidy
sudo apt-get -y install php7.2-xmlrpc
sudo apt-get -y install php7.2-zip
sudo apt-get -y install php7.2-ssh2
sudo apt-get -y install php7.2-msgpack
sudo apt-get -y install php7.2-opcache
sudo apt-get -y install php7.2-readline
sudo apt-get -y install php7.2-igbinary
sudo apt-get -y install php7.2-memcache 
sudo apt-get -y install php7.2-memcached 
sudo apt-get -y install php7.2-mysql

# Enchant
sudo apt-get -y install libenchant-dev
sudo apt-get -y install php7.2-enchant

# LDAP
sudo apt-get -y install ldap-utils
sudo apt-get -y install php7.2-ldap

# CURL
sudo apt-get -y install curl
sudo apt-get -y install php7.2-curl

# IMAGE MAGIC
sudo apt-get -y install imagemagick
sudo apt-get -y install php7.2-imagick

reboot_webserver_helper

$pkg='re2c'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
echo "Adding Phalcon to PHP"
# Phalcon
sudo apt-get -y install re2c
sudo git clone --depth=1 -b 3.3.x  "git://github.com/phalcon/cphalcon.git"
cd cphalcon/build && sudo ./install
sudo echo "extension=phalcon.so" > /etc/php/7.2/mods-available/phalcon.ini
cd ../../ && sudo rm -rf cphalcon
fi

fi

# /*===========================================
# =            CUSTOM PHP SETTINGS            =
# ===========================================*/
PHP_USER_INI_PATH=/etc/php/7.2/apache2/conf.d/user.ini
echo "Enabling debug"
echo 'display_startup_errors = On' | sudo tee -a $PHP_USER_INI_PATH
echo 'display_errors = On' | sudo tee -a $PHP_USER_INI_PATH
echo 'error_reporting = E_ALL' | sudo tee -a $PHP_USER_INI_PATH
echo 'short_open_tag = On' | sudo tee -a $PHP_USER_INI_PATH
reboot_webserver_helper

echo "Updating PHP limits."
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.2/apache2/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.2/apache2/php.ini
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.2/cli/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.2/cli/php.ini
reboot_webserver_helper

# Disable PHP Zend OPcache
echo 'opache.enable = 0' | sudo tee -a $PHP_USER_INI_PATH

# Absolutely Force Zend OPcache off...
sudo sed -i s,\;opcache.enable=0,opcache.enable=0,g /etc/php/7.2/apache2/php.ini
reboot_webserver_helper

# /*================================
# =            PHP UNIT            =
# ================================*/
sudo wget https://phar.phpunit.de/phpunit-7.0.2.phar
sudo chmod +x phpunit-7.0.2.phar
sudo mv phpunit-7.0.2.phar /usr/local/bin/phpunit
reboot_webserver_helper

$pkg='postgresql-10'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
echo "Setting up PostGres 10"
# /*=================================
# =            PostreSQL            =
# =================================*/
sudo add-apt-repository 'deb http://apt.postgresql.org/pub/repos/apt/ zesty-pgdg main'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -
sudo apt-get -qq update
sudo apt-get -y install postgresql-10 postgresql-contrib
echo "CREATE ROLE root WITH LOGIN ENCRYPTED PASSWORD 'root';" | sudo -i -u postgres psql
sudo apt-get -y install php7.2-pgsql
sudo systemctl stop postgresql
sudo pg_dropcluster 10 main --stop
sudo pg_upgradecluster -m upgrade 9.5 main
sudo pg_dropcluster 9.5 main --stop
sudo systemctl start postgresql
fi
reboot_webserver_helper

$pkg='unixodbc-dev'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
echo "Setting up Microsoft SQL connector"
# /*=================================
# =            NMSSQL              =
# =================================*/
curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo bash -c "curl -s https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list"
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get -y install msodbcsql mssql-tools
sudo apt-get -y install unixodbc-dev
sudo apt-get -y install gcc g++ make autoconf libc-dev pkg-config
sudo pecl install sqlsrv
sudo pecl install pdo_sqlsrv
sudo bash -c "echo extension=sqlsrv.so > /etc/php7.2/conf.d/sqlsrv.ini"
sudo bash -c "echo extension=pdo_sqlsrv.so > /etc/php7.2/conf.d/pdo_sqlsrv.ini"
fi
reboot_webserver_helper

$pkg='sqlite3'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
# /*==============================
# =            SQLITE            =
# ===============================*/
sudo apt-get -y install sqlite
sudo apt-get -y install php7.2-sqlite3
fi
reboot_webserver_helper

if [ ! -f "/lib/systemd/system/mongod.service" ]
then
# /*===============================
# =            MONGODB            =
# ===============================*/
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org

sudo tee /lib/systemd/system/mongod.service  <<EOL
[Unit]
Description=High-performance, schema-free document-oriented database
After=network.target
Documentation=https://docs.mongodb.org/manual
[Service]
User=mongodb
Group=mongodb
ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable mongod
sudo service mongod start

# Enable it for PHP
sudo pecl install mongodb
sudo apt-get install -y php7.2-mongodb
if
reboot_webserver_helper

# /*================================
# =            COMPOSER            =
# ================================*/
if ! type composer > /dev/null; then
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
php composer-setup.php --quiet
rm composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod 755 /usr/local/bin/composer
fi

sudo a2enmod php7.2
sudo a2enmod http2

composer g require psy/psysh:@stable
composer g require friendsofphp/php-cs-fixer

$pkg='beanstalkd'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
# /*==================================
# =            BEANSTALKD            =
# ==================================*/
sudo apt-get -y install beanstalkd
fi

# /*==============================
# =            WP-CLI            =
# ==============================*/
if [ ! -f "/usr/local/bin/wp" ]
then
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
if

# /*=============================
# =            DRUSH            =
# =============================*/
#wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.5.1/drush.phar
#sudo chmod +x drush.phar
#sudo mv drush.phar /usr/local/bin/drush

#Better drush
$pkg='drush'
if [ ! -f "/usr/local/src/drush" ]
then
sudo apt-get remove drush
sudo git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
cd /usr/local/src/drush
sudo git checkout 7.4.0  #or whatever version you want.
sudo ln -s /usr/local/src/drush/drush /usr/bin/drush
sudo composer install
fi
reboot_webserver_helper


$pkg='ngrok-client'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
# /*=============================
# =            NGROK            =
# =============================*/
sudo apt-get install ngrok-client
fi

# /*==============================
# =            NODEJS            =
# ==============================*/
sudo apt-get -y install nodejs
sudo apt-get -y install npm

if [ ! -f "/home/vagrant/.nvm/nvm.sh" ]
then
# Use NVM though to make life easy
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 8.9.4
nvm use 8.9.4
nvm alias default 8.9.4

# Node Packages
sudo npm install -g npm
sudo npm install -g gulp
sudo npm install -g grunt
sudo npm install -g bower
sudo npm install -g yo
sudo npm install -g browser-sync
sudo npm install -g browserify
sudo npm install -g pm2
sudo npm install -g webpack
fi

# /*============================
# =            YARN            =
# ============================*/
$pkg='yarn'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -qq update
sudo apt-get -y install yarn
fi

# /*============================
# =            RUBY            =
# ============================*/
sudo apt-get -y install ruby
sudo apt-get -y install ruby-dev

if [ ! -f "/etc/profile.d/rvm.sh" ] then
# Use RVM though to make life easy
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.5.0
rvm use 2.5.0

gem update
gem install net-sftp net-ssh
gem clean
fi

$pkg='redis-server'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
# /*=============================
# =            REDIS            =
# =============================*/
sudo apt-get -y install redis-server
sudo apt-get -y install php7.2-redis
reboot_webserver_helper
fi

$pkg='memcached'
if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
# /*=================================
# =            MEMCACHED            =
# =================================*/
sudo apt-get -y install memcached
sudo apt-get -y install php7.2-memcached
sudo phpenmod memcache
sudo phpenmod memcached
if

reboot_webserver_helper


# /*==============================
# =            GOLANG            =
# ==============================*/
if ! type golang-go > /dev/null; then
echo "Adding Go"
sudo apt-get -qq update
sudo apt-get -y dist-upgrade
sudo apt-get -y install golang-go
fi

# /*===============================
# =            MAILHOG            =
# ===============================*/
if [ ! -f "/etc/systemd/system/mailhog.service" ]
then
sudo wget --quiet -O ~/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
sudo chmod +x ~/mailhog

# Enable and Turn on
sudo tee /etc/systemd/system/mailhog.service <<EOL
[Unit]
Description=MailHog Service
After=network.service vagrant.mount
[Service]
Type=simple
ExecStart=/usr/bin/env /home/vagrant/mailhog > /dev/null 2>&1 &
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable mailhog
sudo systemctl start mailhog

# Install Sendmail replacement for MailHog
sudo go get github.com/mailhog/mhsendmail
sudo ln ~/go/bin/mhsendmail /usr/bin/mhsendmail
sudo ln ~/go/bin/mhsendmail /usr/bin/sendmail
sudo ln ~/go/bin/mhsendmail /usr/bin/mail

echo 'sendmail_path = /usr/bin/mhsendmail' | sudo tee -a /etc/php/7.2/apache2/conf.d/user.ini
fi

reboot_webserver_helper

# /*===============================
# =            VSFTPD            =
# ===============================*/
if [ ! -f "/etc/vsftpd.conf" ]
then
echo "Added and enabled VSFTPD. Restarting VSFTPD..."
sudo apt-get install vsftpd
sudo wget https://gist.github.com/anonymous/1204611 /etc/vsftpd.conf
sudo service vsftpd restart
fi

# /*===============================
# =   METEOR & REACTIONCOMMERCE   =
# ===============================*/
# Add in MeteorJS
if ! type meteor > /dev/null; then
    echo "Add Meteor & Reaction Commerce"
    sudo curl -k https://install.meteor.com/ | sh
    sudo npm install -g reaction-cli
fi

# Add Composer to PATH.
export PATH="~/.composer/vendor/bin:$PATH"

# Setup dnsmasq for VM.
echo -e "address=/$3/$2" | sudo tee /etc/dnsmasq.d/$3
sudo /etc/init.d/dnsmasq restart

# Setup the files for level vhost (nothing to be shown there ATM).
# @TODO Get the ScotchBox index.php to serve from there.
sudo mkdir -p /var/www/public
sudo touch /var/www/public/index.html

# Convert the first arg var passed in (a comma-separated list of
# the domains provided to hostmanager) to an array of domains.
DOMAINS_STR=($1)
DOMAINS_ARR=(${DOMAINS_STR//,/ })

## Loop through all sites
for ((i=0; i < ${#DOMAINS_ARR[@]}; i++)); do

    ## Current Domain
    DOMAIN=${DOMAINS_ARR[$i]}

    echo "Creating directories for $DOMAIN..."
    mkdir -p /var/www/vhosts/$DOMAIN/public
    mkdir -p /var/www/vhosts/$DOMAIN/logs

    echo "Creating SSL config for $DOMAIN..."
    mkdir -p /var/www/vhosts/$DOMAIN/certs
    cd /var/www/vhosts/$DOMAIN/certs
    openssl genrsa -out $DOMAIN.key 2048
    openssl req -new -x509 -sha256 -key $DOMAIN.key -out $DOMAIN.cert -days 3650 -subj /CN=$DOMAIN
    echo "Creating vhost config for $DOMAIN..."
    cat << VIRTUALHOSTCONF > /etc/apache2/sites-available/$DOMAIN.conf
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  ServerName $DOMAIN
  ServerAlias *.$DOMAIN
  DocumentRoot /var/www/vhosts/$DOMAIN/public
  DirectoryIndex index.html index.php
  ErrorLog /var/www/vhosts/$DOMAIN/logs/error.log
  CustomLog /var/www/vhosts/$DOMAIN/logs/access.log combined
    <Directory "/var/www/vhosts/$DOMAIN/public">
        Options All
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost *:443>
  SSLEngine On
  SSLCertificateFile /var/www/vhosts/$DOMAIN/certs/$DOMAIN.cert 
  SSLCertificateKeyFile /var/www/vhosts/$DOMAIN/certs/$DOMAIN.key 
  ServerAdmin webmaster@localhost
  ServerName $DOMAIN
  ServerAlias *.$DOMAIN
  DocumentRoot /var/www/vhosts/$DOMAIN/public
  ErrorLog /var/www/vhosts/$DOMAIN/logs/error.log
  CustomLog /var/www/vhosts/$DOMAIN/logs/access.log combined
      <Directory "/var/www/vhosts/$DOMAIN/public">
        Options All
        AllowOverride All
        Require all granted
    </Directory> 
</VirtualHost>
VIRTUALHOSTCONF

    echo "Enabling $DOMAIN..."
    sudo a2ensite $DOMAIN.conf

done

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

# /*====================================
# =            YOU ARE DONE            =
# ====================================*/
echo 'Booooooooom! We are done. You are a hero. I love you.'