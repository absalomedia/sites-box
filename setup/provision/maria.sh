#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Print text when running vagrant up.
echo "Making sure MariaDB externally accessible"

sudo nano /etc/mysql/my.cnf
change:
bind-address            = 0.0.0.0


mysql -u root -p

use mysql
GRANT ALL ON *.* to root@'10.0.2.2';
FLUSH PRIVILEGES;
exit


sudo /etc/init.d/mysql restart