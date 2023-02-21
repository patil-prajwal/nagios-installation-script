#!/bin/bash

### Script to install Nagios Core and Nagios Plugins on Linux

# Tested on Amazon Linux on 21-02-2023


# Install necessary libraries
sudo su
yum install httpd php -y
yum install gcc glibc glibc-common -y
yum install gd gd-devel openssl-devel -y

# Add a user for nagios and password for it..
adduser -m nagios
passwd nagios

# Create a user-group and nagios and apache users to it
groupadd nagioscmd
usermod -a -G nagioscmd nagios
usermod -a -G nagioscmd apache

# Download the tarball for Nagios Core and Nagios Plugins
mkdir ~/downloads
cd ~/downloads
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.4.10.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-2.4.3.tar.gz

# Extract & build the tarball to Nagios Core
tar zxvf nagios-4.4.10.tar.gz
cd nagios-4.4.10
./configure --with-command-group=nagioscmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf

# Create a username and password to access the WebUI of Nagios - Here "nagiosadmin" is username to be created
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Restart the httpd service to take effect
service httpd restart

# Now, Let's extract and build the Nagios plugins for Core
cd ~/downloads
tar zxvf nagios-plugins-2.4.3.tar.gz
cd nagios-plugins-2.4.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

# Check whether the confir files are good to go
chkconfig --add nagios
chkconfig nagios on

# Check whether config files have some errors are not
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# Run the Nagios service and then restart the httpd server.
service nagios start
service httpd restart


##    Visit : "http://<IP-Address>/nagios"  to access the WebUI by entering the above entered username and password...