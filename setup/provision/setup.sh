#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

phpversion="$(php --version | tail -r | tail -n 1 | cut -d " " -f 2 | cut -c 1,1)"

# Print text when running vagrant up.
echo "Starting VM..."

if [ $(echo " $phpversion > 7" | bc) -eq 1 ]; then
    # Drop in MariaDB && HHVM & PHP7.1 
    sudo apt-get install software-properties-common
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.aarnet.edu.au/pub/MariaDB/repo/10.1/ubuntu trusty main'
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
    sudo add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
    sudo add-apt-repository ppa:ondrej/php
    sudo add-apt-repository ppa:ondrej/apache2
fi

# Keep packages up to date.
sudo apt-get update
sudo apt-get upgrade -y --force-yes
sudo apt-get dist-upgrade -y --force-yes
# Update Apache to latest edition
sudo apt-get upgrade apache2 -y --force-yes
sudo apt-get autoremove

if [ $(echo " $phpversion > 7" | bc) -eq 1 ]; then
    sudo a2dismod php5
    sudo apt-get purge 'php5.6*'
    # Remove PHP5.6 repo in prep for 7.1
    sudo rm /etc/apt/sources.list.d/ondrej-php5-5*

    sudo apt-get install php7.1 php7.1-cli php7.1-common php7.1-mysql php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-mongo libapache2-mod-php7.1 php7.1-redis php7.1-intl php7.1-tidy php7.1-readline php7.1-xdebug php7.1-ssh2 php7.1-json php7.1-mcrypt php7.1-curl php7.1-gd php-uploadprogress php7.1-apc php7.1-xml php7.1-mbstring php7.1-imagick php-xhprof php-memcache php-memcached php-mongo php-libsodium blackfire-php sendmail redis-server locate -y --force-yes

    sudo cp /etc/php5/mods-available/mailcatcher.ini /etc/php/7.1/mods-available/mailcatcher.ini
    sudo cp /etc/php5/mods-available/memcache.ini /etc/php/7.1/mods-available/memcache.ini
    sudo cp /etc/php5/mods-available/memcached.ini /etc/php/7.1/mods-available/memcached.ini
    sudo a2enmod php7.1
    sudo a2enmod http2
    sudo phpenmod mailcatcher
    sudo phpenmod memcache
    sudo phpenmod memcached
fi

# Add extras not included w/scotchbox.
sudo apt-get install subversion openjdk-7-jre-headless nfs-common nfs-kernel-server dnsmasq pkg-config cmake php-codesniffer phpunit libssh2-1-dev libssh2-php drush vsftpd -y --force-yes

sudo apt-get install mariadb-server mariadb-client hhvm -y --force-yes
# sudo /usr/share/hhvm/install_fastcgi.sh
sudo service apache2 restart
sudo service mysql restart

# Add in MeteorJS
if ! type meteor > /dev/null; then
    sudo curl -k https://install.meteor.com/ | sh
    sudo npm install -g reaction-cli
fi

# Install Codeception if it isn't already here.
if ! type codecept > /dev/null; then
  sudo wget http://codeception.com/codecept.phar -O /usr/local/bin/codecept
  sudo chmod +x /usr/local/bin/codecept
fi

# Install RVM if it isn't already here.
# @see https://rvm.io/rvm/install
if ! type rvm > /dev/null; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  \curl -sSL https://get.rvm.io | bash -s stable --ruby
  source /home/vagrant/.rvm/scripts/rvm
fi

# Gems - update, install some not included w/scotchbox, RVM.
gem update
gem install compass net-sftp net-ssh
gem clean

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


echo "Added and enabled vhosts. Updating PHP limits. Restarting Apache..."
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.1/apache2/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.1/apache2/php.ini
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.1/cli/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.1/cli/php.ini
sudo service apache2 restart
echo "Added and enabled VSFTPD. Restarting VSFTPD..."
sudo apt-get install vsftpd
sudo wget https://gist.github.com/anonymous/1204611 /etc/vsftpd.conf
sudo service vsftpd restart
