#!/bin/bash

# /*=================================
# =            VARIABLES            =
# =================================*/
WELCOME_MESSAGE='
Happy Happy Joy Joy
'

reboot_webserver_helper() {
    sudo service apache2 restart
    echo 'Rebooting your webserver'
}


echo "Starting VM..."
sudo apt-get update

# The following is "sudo apt-get -y upgrade" without any prompts
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

sudo apt-get install -y build-essential
sudo apt-get install -y tcl
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo apt-get -y install vim
sudo apt-get -y install dnsmasq
sudo apt-get -y install git

# Weird Vagrant issue fix
sudo apt-get install -y ifupdown

echo "Updating Apache..."
sudo add-apt-repository -y ppa:ondrej/apache2 # Super Latest Version
sudo apt-get update
sudo apt-get -y install apache2

sudo a2enmod expires
sudo a2enmod headers
sudo a2enmod include
sudo a2enmod rewrite

sudo service apache2 restart

echo "Updating PHP"
sudo add-apt-repository -y ppa:ondrej/php # Super Latest Version (currently 7.2)
sudo apt-get update
sudo apt-get install -y php7.2
sudo apt-get -y install libapache2-mod-php

    # Add index.php to readable file types
    MAKE_PHP_PRIORITY='<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
    </IfModule>'
    echo "$MAKE_PHP_PRIORITY" | sudo tee /etc/apache2/mods-enabled/dir.conf

sudo service apache2 restart

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

echo "Adding Phalcon to PHP"
# Phalcon
sudo curl -s "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh" | sudo bash
sudo apt-get -y install php7.2-phalcon



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
sudo wget https://phar.phpunit.de/phpunit-6.1.phar
sudo chmod +x phpunit-6.1.phar
sudo mv phpunit-6.1.phar /usr/local/bin/phpunit
reboot_webserver_helper

# /*=============================
# =            MYSQL            =
# =============================*/
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
sudo mysqladmin -uroot -proot create scotchbox
sudo apt-get -y install php7.2-mysql
reboot_webserver_helper


# /*=================================
# =            PostreSQL            =
# =================================*/
sudo apt-get -y install postgresql postgresql-contrib
echo "CREATE ROLE root WITH LOGIN ENCRYPTED PASSWORD 'root';" | sudo -i -u postgres psql
sudo -i -u postgres createdb --owner=root scotchbox
sudo apt-get -y install php7.2-pgsql
reboot_webserver_helper


# /*==============================
# =            SQLITE            =
# ===============================*/
sudo apt-get -y install sqlite
sudo apt-get -y install php7.2-sqlite3
reboot_webserver_helper


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

reboot_webserver_helper

# /*================================
# =            COMPOSER            =
# ================================*/
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
php composer-setup.php --quiet
rm composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod 755 /usr/local/bin/composer

sudo a2enmod php7.2
sudo a2enmod http2
sudo phpenmod memcache
sudo phpenmod memcached

# /*==================================
# =            BEANSTALKD            =
# ==================================*/
sudo apt-get -y install beanstalkd

# /*==============================
# =            WP-CLI            =
# ==============================*/
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# /*=============================
# =            DRUSH            =
# =============================*/
#wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.5.1/drush.phar
#sudo chmod +x drush.phar
#sudo mv drush.phar /usr/local/bin/drush

#Better drush
sudo apt-get remove drush
sudo git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
cd /usr/local/src/drush
sudo git checkout 7.4.0  #or whatever version you want.
sudo ln -s /usr/local/src/drush/drush /usr/bin/drush
sudo composer install


# /*=============================
# =            NGROK            =
# =============================*/
sudo apt-get install ngrok-client

# /*==============================
# =            NODEJS            =
# ==============================*/
sudo apt-get -y install nodejs
sudo apt-get -y install npm

# Use NVM though to make life easy
wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | bash
source ~/.nvm/nvm.sh
nvm install 8.9.4

# Node Packages
sudo npm install -g gulp
sudo npm install -g grunt
sudo npm install -g bower
sudo npm install -g yo
sudo npm install -g browser-sync
sudo npm install -g browserify
sudo npm install -g pm2
sudo npm install -g webpack


# /*============================
# =            YARN            =
# ============================*/
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get -y install yarn

# /*============================
# =            RUBY            =
# ============================*/
sudo apt-get -y install ruby
sudo apt-get -y install ruby-dev

# Use RVM though to make life easy
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.5.0
rvm use 2.5.0

gem update
gem install net-sftp net-ssh
gem clean



# /*=============================
# =            REDIS            =
# =============================*/
sudo apt-get -y install redis-server
sudo apt-get -y install php7.2-redis
reboot_webserver_helper

# /*=================================
# =            MEMCACHED            =
# =================================*/
sudo apt-get -y install memcached
sudo apt-get -y install php7.2-memcached
reboot_webserver_helper


# /*==============================
# =            GOLANG            =
# ==============================*/
sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt-get update
sudo apt-get -y install golang-go


# /*===============================
# =            MAILHOG            =
# ===============================*/
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

reboot_webserver_helper

echo "Added and enabled VSFTPD. Restarting VSFTPD..."
sudo apt-get install vsftpd
sudo wget https://gist.github.com/anonymous/1204611 /etc/vsftpd.conf
sudo service vsftpd restart

#echo "Add Meteor & Reaction Commerce"
# Add in MeteorJS
if ! type meteor > /dev/null; then
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
</VirtualHost>
VIRTUALHOSTCONF

    echo "Enabling $DOMAIN..."
    sudo a2ensite $DOMAIN.conf

done

# /*=======================================
# =            WELCOME MESSAGE            =
# =======================================*/

# Disable default messages by removing execute privilege
sudo chmod -x /etc/update-motd.d/*

# Set the new message
echo "$WELCOME_MESSAGE" | sudo tee /etc/motd

# /*===================================================
# =            FINAL GOOD MEASURE, WHY NOT            =
# ===================================================*/
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
reboot_webserver_helper

# /*====================================
# =            YOU ARE DONE            =
# ====================================*/
echo 'Booooooooom! We are done. You are a hero. I love you.'