#!/bin/bash

# /*=================================
# =            VARIABLES            =
# =================================*/
reboot_webserver_helper() {
    sudo service apache2 restart
    sudo apt -y autoremove
    sudo apt-get -y autoremove
    echo 'Rebooting your webserver'
}

echo "Building VM..."
sudo apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

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

sudo apt-get install -y php7.4
sudo apt-get -y install libapache2-mod-php

    # Add index.php to readable file types
    MAKE_PHP_PRIORITY='<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
    </IfModule>'
    echo "$MAKE_PHP_PRIORITY" | sudo tee /etc/apache2/mods-enabled/dir.conf

reboot_webserver_helper

sudo apt-get -y install php7.4-common
sudo apt-get -y install php7.4-dev

# Common Useful Stuff (some of these are probably already installed)
sudo apt-get -y install php7.4-bcmath
sudo apt-get -y install php7.4-bz2
sudo apt-get -y install php7.4-cgi
sudo apt-get -y install php7.4-curl
sudo apt-get -y install php7.4-cli
sudo apt-get -y install php7.4-fpm
sudo apt-get -y install php7.4-gd
sudo apt-get -y install php7.4-imap
sudo apt-get -y install php7.4-intl
sudo apt-get -y install php7.4-json
sudo apt-get -y install php7.4-mbstring
sudo apt-get -y install php7.4-odbc
sudo apt-get -y install php-pear
sudo apt-get -y install php7.4-pspell
sudo apt-get -y install php7.4-tidy
sudo apt-get -y install php7.4-xmlrpc
sudo apt-get -y install php7.4-zip
sudo apt-get -y install php7.4-ssh2
sudo apt-get -y install php7.4-msgpack
sudo apt-get -y install php7.4-opcache
sudo apt-get -y install php7.4-readline
sudo apt-get -y install php7.4-igbinary
sudo apt-get -y install php7.4-memcache 
sudo apt-get -y install php7.4-memcached 
sudo apt-get -y install php7.4-psr
sudo apt-get -y install php7.4-mysql
sudo apt-get -y install php7.4-xml
sudo apt-get -y install php7.4-zip

# Enchant
sudo apt-get -y install libenchant-dev
sudo apt-get -y install php7.4-enchant

# LDAP
sudo apt-get -y install ldap-utils
sudo apt-get -y install php7.4-ldap

# CURL
sudo apt-get -y install curl
sudo apt-get -y install php7.4-curl

# IMAGE MAGIC
sudo apt-get -y install imagemagick
sudo apt-get -y install php7.4-imagick

reboot_webserver_helper

echo "Adding latest Phalcon to PHP"
# Phalcon
sudo curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash
sudo apt-get -y install php7.4-phalcon


# /*===========================================
# =            CUSTOM PHP SETTINGS            =
# ===========================================*/
PHP_USER_INI_PATH=/etc/php/7.4/apache2/conf.d/user.ini
echo "Enabling debug"
echo 'display_startup_errors = On' | sudo tee -a $PHP_USER_INI_PATH
echo 'display_errors = On' | sudo tee -a $PHP_USER_INI_PATH
echo 'error_reporting = E_ALL' | sudo tee -a $PHP_USER_INI_PATH
echo 'short_open_tag = On' | sudo tee -a $PHP_USER_INI_PATH
reboot_webserver_helper

echo "Updating PHP limits."
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.4/apache2/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.4/apache2/php.ini
sudo sed -ie 's/ 128M/ 256M/g' /etc/php/7.4/apache2/php.ini
sudo sed -ie 's/ 1000/ 10000/g' /etc/php/7.4/apache2/php.ini
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.4/cli/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.4/cli/php.ini
sudo sed -ie 's/ 128M/ 256M/g' /etc/php/7.4/cli/php.ini
sudo sed -ie 's/ 1000/ 10000/g' /etc/php/7.4/cli/php.ini
sudo sed -ie 's/ ; max_input_vars / max_input_vars /g' /etc/php/7.4/apache2/php.ini
sudo sed -ie 's/ ; max_input_vars / max_input_vars /g' /etc/php/7.4/cli/php.ini

reboot_webserver_helper

# Disable PHP Zend OPcache
echo 'opache.enable = 0' | sudo tee -a $PHP_USER_INI_PATH

# Absolutely Force Zend OPcache off...
sudo sed -i s,\;opcache.enable=0,opcache.enable=0,g /etc/php/7.4/apache2/php.ini
reboot_webserver_helper

# /*================================
# =            PHP UNIT            =
# ================================*/
sudo wget https://phar.phpunit.de/phpunit-7.0.2.phar
sudo chmod +x phpunit-7.0.2.phar
sudo mv phpunit-7.0.2.phar /usr/local/bin/phpunit
reboot_webserver_helper

echo "Setting up PostGres 10"
# /*=================================
# =            PostreSQL            =
# =================================*/
echo "CREATE ROLE root WITH LOGIN ENCRYPTED PASSWORD 'root';" | sudo -i -u postgres psql
sudo apt-get -y install php7.4-pgsql
sudo systemctl stop postgresql
sudo pg_dropcluster 10 main --stop
sudo pg_upgradecluster -m upgrade 9.5 main
sudo pg_dropcluster 9.5 main --stop
sudo systemctl start postgresql
reboot_webserver_helper

echo "Setting up Microsoft SQL connector"
# /*=================================
# =            NMSSQL              =
# =================================*/
curl -s https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo bash -c "curl -s https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list"
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get -y install msodbcsql mssql-tools
sudo apt-get -y install unixodbc-dev
sudo apt-get -y install gcc g++ make autoconf libc-dev pkg-config
sudo pecl install sqlsrv
sudo pecl install pdo_sqlsrv
sudo bash -c "echo extension=sqlsrv.so > /etc/php7.4/conf.d/sqlsrv.ini"
sudo bash -c "echo extension=pdo_sqlsrv.so > /etc/php7.4/conf.d/pdo_sqlsrv.ini"
reboot_webserver_helper

# /*==============================
# =            SQLITE            =
# ===============================*/
sudo apt-get -y install sqlite
sudo apt-get -y install php7.4-sqlite3
reboot_webserver_helper

# /*===============================
# =            MONGODB            =
# ===============================*/
# Enable it for PHP
sudo pecl install mongodb
sudo apt-get install -y php7.4-mongodb
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

sudo a2enmod php7.4
sudo a2enmod http2

composer g require psy/psysh:@stable
# /*==============================
# =            CS FIXER          =
# ==============================*/
composer g require friendsofphp/php-cs-fixer

# /*==============================
# =            WP-CLI            =
# ==============================*/
composer g require wp-cli/wp-cli-bundle

# /*==================================
# =            BEANSTALKD            =
# ==================================*/
sudo apt-get -y install beanstalkd

# /*==================================
# =            HEROKU                =
# ==================================*/
sudo snap install --classic heroku

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# /*=============================
# =            DRUSH            =
# =============================*/

#Better drush
$pkg='drush'
if [ ! -f "/usr/local/src/drush" ]
then
sudo apt-get remove drush
sudo composer global require consolidation/cgr
sudo PATH="$(composer config home)/vendor/bin:$PATH"
sudo cgr drush/drush:8
fi
reboot_webserver_helper


# /*=============================
# =            NGROK            =
# =============================*/
sudo apt-get install ngrok-client


# /*=============================
# =            RETHINKDB        =
# =============================*/
source /etc/lsb-release && echo "deb https://download.rethinkdb.com/repository/ubuntu-$DISTRIB_CODENAME $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
wget -qO- https://download.rethinkdb.com/repository/raw/pubkey.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install rethinkdb

# /*==============================
# =            NODEJS            =
# ==============================*/
sudo apt-get -y install nodejs
sudo apt-get -y install npm

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

# /*============================
# =            YARN            =
# ============================*/
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get -qq update
sudo apt-get -y install yarn

# /*============================
# =            RUBY            =
# ============================*/

# Use RVM though to make life easy
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
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
sudo apt-get -y install php7.4-redis
reboot_webserver_helper

# /*=================================
# =            MEMCACHED            =
# =================================*/
sudo apt-get -y install memcached
sudo apt-get -y install php7.4-memcached
sudo phpenmod memcache
sudo phpenmod memcached
reboot_webserver_helper

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

echo 'sendmail_path = /usr/bin/mhsendmail' | sudo tee -a /etc/php/7.4/apache2/conf.d/user.ini
reboot_webserver_helper

# /*===============================
# =            VSFTPD            =
# ===============================*/
echo "Added and enabled VSFTPD. Restarting VSFTPD..."
sudo apt-get install vsftpd
sudo wget https://gist.github.com/anonymous/1204611 /etc/vsftpd.conf
sudo service vsftpd restart

