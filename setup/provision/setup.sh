#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Print text when running vagrant up.
echo "Starting VM..."

echo "Dropping PHP 5.6"
#Drop PHP5.6 repo
sudo rm /etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list
sudo rm /etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list.save
# Drop in MariaDB & PHP7.2 
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mirror.aarnet.edu.au/pub/MariaDB/repo/10.2/ubuntu trusty main'
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:ondrej/apache2

# Gems - update, install some not included w/scotchbox, RVM.
gem update
gem install net-sftp net-ssh
gem clean

# echo "@reboot root $(which mailcatcher) --ip=0.0.0.0" >> /etc/crontab
update-rc.d cron defaults

# Keep packages up to date.
sudo apt-get update
sudo apt-get upgrade -y --force-yes
sudo apt-get dist-upgrade -y --force-yes
# Update Apache to latest edition
sudo apt-get upgrade apache2 -y --force-yes

sudo a2dismod php7.0

sudo apt-get install php7.2 php7.2-cli php7.2-common php7.2-mysql php7.2-fpm php7.2-enchant php7.2-pgsql php7.2-sqlite3 php7.2-mongo libapache2-mod-php7.2 php7.2-redis php7.2-intl php7.2-tidy php7.2-readline php7.2-xdebug php7.2-ssh2 php7.2-json php7.2-mcrypt php7.2-dev php7.2-curl php7.2-gd php-uploadprogress php7.2-apc php7.2-xml php7.2-mbstring php7.2-imagick php-memcache php-memcached php-mongo php-libsodium blackfire-php redis-server locate git nfs-common nfs-kernel-server dnsmasq pkg-config cmake -y --force-yes
sudo apt-get install mariadb-server mariadb-client -y --force-yes

sudo cp /etc/php5/mods-available/mailcatcher.ini /etc/php/7.2/mods-available/mailcatcher.ini
sudo cp /etc/php/7.0/mods-available/memcache.ini /etc/php/7.2/mods-available/memcache.ini
sudo cp /etc/php/7.0/mods-available/memcached.ini /etc/php/7.2/mods-available/memcached.ini

sudo a2enmod php7.2
sudo a2enmod http2
sudo phpenmod mailcatcher
sudo phpenmod memcache
sudo phpenmod memcached

# sudo /usr/share/hhvm/install_fastcgi.sh
sudo service apache2 restart
sudo service mysql restart

#echo "Add Meteor & Reaction Commerce"
# Add in MeteorJS
if ! type meteor > /dev/null; then
    sudo curl -k https://install.meteor.com/ | sh
    sudo npm install -g reaction-cli
fi

echo "Add CodeCeption"
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

# Add Composer to PATH.
export PATH="~/.composer/vendor/bin:$PATH"

# Setup dnsmasq for VM.
echo -e "address=/$3/$2" | sudo tee /etc/dnsmasq.d/$3
sudo /etc/init.d/dnsmasq restart

#Better drush
sudo apt-get remove drush
sudo git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
cd /usr/local/src/drush
sudo git checkout 7.4.0  #or whatever version you want.
sudo ln -s /usr/local/src/drush/drush /usr/bin/drush
sudo composer install

#MailHog
echo ">>> Installing Mailhog"

# Download binary from github
sudo wget --quiet -O ~/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64

# Make it executable
sudo chmod +x ~/mailhog

# Make it start on reboot
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

# moving mailhog to init.d
`sudo mv ~/mailhog /etc/init.d/mailhog`

# updating service mailhog
`sudo update-rc.d mailhog defaults`


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

echo "Remove PHP5 and PHP 7.0"
sudo apt-get remove --auto-remove php7.0-common -y
sudo apt-get remove --auto-remove php5-common -y

echo "Update MongoDB driver & Upload Progress"
sudo pecl channel-update pecl.php.net
sudo pecl install mongodb

echo "Added and enabled vhosts. Updating PHP limits. Restarting Apache..."
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.2/apache2/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.2/apache2/php.ini
sudo sed -ie 's/ 2M/ 24M/g' /etc/php/7.2/cli/php.ini
sudo sed -ie 's/ 8M/ 24M/g' /etc/php/7.2/cli/php.ini
sudo service apache2 restart
echo "Added and enabled VSFTPD. Restarting VSFTPD..."
sudo apt-get install vsftpd
sudo wget https://gist.github.com/anonymous/1204611 /etc/vsftpd.conf
sudo service vsftpd restart
