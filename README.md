# sites-box 3.5

An extension of the [Scotch Box](https://box.scotch.io/) Vagrant lamp stack configured for hosting multiple sites in one box.

Includes:

* Built off latest Scotch Box (version 3.5)
* PHP 7.2
* The latest [Phalcon 3.3.x](https://phalconphp.com/)
* PostgreSQL [10](https://www.postgresql.org/)
* FTP access using [VSFTP](https://security.appspot.com/vsftpd.html)
* [Drush](http://www.drush.org/) (Drush 8.1.7 for client compatibility with Drupal 7)
* Ability to set multi core CPUs & increased VM memory
* [Mailhog](https://github.com/mailhog/MailHog)
* Microsoft Drivers for PHP for [SQL Server](https://github.com/Microsoft/msphpsql)
* SSL enabled virtual hosts (self-signed based on config.yaml)
* DNSMasq detection for Windows hosts
* Latest edition of [MeteorJS](https://www.meteor.com) installed
* Latest edition of [Reaction Commerce](https://reactioncommerce.com/) installed
* Apache virtual host directory now customised in config.yaml file
* MySQL 5.7 custom configuration with utf8mb4 encoded database setup
* MySQL data directory is now a synced folder to stop you losing data on when Vagrant image is destroyed
* MySQL synced folder now customised in config.yaml file
* Simplified MySQL access - it's now seen as local instead of the standard SSH connection
* Database backup & restore scripts

Setup requires:

* VirtualBox ([binaries available here](https://www.virtualbox.org/wiki/Downloads))
* Vagrant ([binaries available here](http://www.vagrantup.com/downloads.html))
* OS-X (for DNS Masq)
* Homebrew (if running on OSX)

---

## Quick reference

These are some notes that might be helpful after you've done the setup. But you need to do the setup first (see next section).

* **Starting the virtual machine:** From the root of this repository, run `vagrant up --provision`
* **Stopping the virtual machine:** From the root of this repository, run `vagrant halt`
* **Restart the virtual machine:** From the root of this repository, run `vagrant reload --provision`
* **My sites aren't showing up in a browser:** Stop the VM and start it up again using `up` and `halt` as described above.
* **Accessing sites via CLI within the VM:** From the root of this repository, run `vagrant ssh` (while the VM is running). That will log you in, just as if you ssh'd to a remote server. **The `sites/` directory where your virtual hosts are located is inside the VM at `/var/www/vhosts/`**. So, you can run `cd /var/www/vhosts` to get there.
* **Connecting to the VM's database using a GUI in your host OS** (such as Sequel Pro): Using a client like Sequel Pro will allow you to connect to MySQL and add/remove databases as you choose, using the following details:
  * MySQL Host: `127.0.0.1`
  * MySQL User: `root`
  * MySQL Password: `root`
  * MySQL Port: `3306`
* **Creating/connecting to a database in the VM:** Say you're developing a WordPress site and need to create a new database and set the connection information in the `wp-config.php` file -- you can use a GUI like Sequel Pro as described above to connect to MySQL then freely create databases as needed. Make a note of the name you use for your project's database, then reference it in your `wp-config.php` database settings (as `DB_NAME`). The other database settings would be:
  * `DB_USER`: `root`
  * `DB_PASSWORD`: ``
  * `DB_HOST`: `localhost`
* **Upgrading:** The virtual machine itself is Scotch Box, and you may get a message that Scotch Box is out of date. To update it, run `vagrant box update` from the root of this repository. Then run `vagrant up` (or, if already running, `vagrant reload`).

---

## Setup

Most of the setup is to get dnsmasq setup on your host machine. It's not strictly necessary, but it'll allow you to use wildcard domains on your sites, which is nice for WordPress multisite and similar projects.

### Setup dnsmasq (Mac only)

* Install dnsmasq via Homebrew: `brew install dnsmasq`
* Run the following commands to setup dnsmasq:

  ```
  cp /usr/local/opt/dnsmasq/dnsmasq.conf.example /usr/local/etc/dnsmasq.conf
  sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
  sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
  ```

* Decide on the hostname and IP you want to use for the VM. For this example, we'll use `dev1` for the hostname and `192.168.33.10` (that's the Scotch Box default) for the IP. Replace those two strings below as needed (or use them if you'd like).
* Then, add the following line to the top of `/usr/local/etc/dnsmasq.conf`:

  ```
  address=/dev1/192.168.33.10
  ```

* Setup the resolver and load up dnsmasq with the following commands:

  ```
  sudo mkdir -v /etc/resolver
  sudo bash -c 'echo "nameserver 192.168.33.10" > /etc/resolver/dev1'
  sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

  # If problems arise or you change something, use the following commands
  # to restart dnsmasq:
  sudo launchctl stop homebrew.mxcl.dnsmasq
  sudo launchctl start homebrew.mxcl.dnsmasq
  ```

### Setup the virtual machine

* Use a terminal to `cd` into the root of this project.
* Make a copy of `config.example.yaml` and rename it `config.yaml`
* Customize `config.yaml` as needed (it's well-commented).
* If using Sites Box on Windows, remember to modify your %SystemRoot%\System32\drivers\etc\hosts files with site list you created
* Start your virtual machine with `vagrant up`

After that, you can visit your (empty) sites in a browser. If you defined a site called `site1` and assigned the hostname `dev1` to your machine, you'll should see it at `http://site1.dev1`. The sites themselves will have directories generated into the `/sites` directory of this project.

Find out more details/docs about using the Scotch Box virtual machine that powers this at <https://box.scotch.io/>.
