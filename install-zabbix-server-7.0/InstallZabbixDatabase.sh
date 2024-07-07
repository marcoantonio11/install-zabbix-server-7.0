#!/bin/bash

#--------------------------------------------------------#
# Script name: Install Zabbix database                   #
# Description: Install and configure MariaDB for Zabbix  #
# Author: Marco Antonio da Silva                         #
# E-mail: marcoa.silva84@gmail.com                       #
# LinkedIn: https://www.linkedin.com/marcosilvarj        #
# Github: https://github.com/marcoantonio11              #
# Use: ./InstallZabbixDatabase.sh                        #
#--------------------------------------------------------#

echo ' '
echo '#####################################################################################'
echo '## This script will install and configure MariaDB for Zabbix.                      ##'
echo '#####################################################################################'
echo ' '

# Check if the passwords and the remote IP address was set
while true; do
   echo '#####################################################################################'
   echo '## Before using this script:                                                       ##'  
   echo '## - Set root and zabbix passwords in the "variables" file;                        ##'
   echo '## - Set the IP adress for remote access in the "variables" file.                  ##'
   echo '##                                                                                 ##'
   echo '## Did you set root and zabbix passwords and the IP address for remote access?     ##'
   echo '## (1) Yes, I set the passwords and the remote IP address. Continue the script.    ##'
   echo '## (2) No, I did not set the passwords or the IP address. Exit the script.         ##'
   echo '#####################################################################################'
   read -p "Chosen option: " ANSWER

   case $ANSWER in
      1) 
         echo -e 'Ok, the script will continue...\n'
         sleep 3
   break
         ;;
      2)
         echo -e 'Ok, the script is closing...\n'
         sleep 2
         exit 1
         ;;
      *) 
         echo -e 'Invalid option! Try again.\n'
	 sleep 1
         ;;
   esac
done

# Identify the distribution
echo 'Identifying the distribution...'
sleep 2
hostnamectl > /tmp/distro.txt
DISTRO=$(sed -nr 's/Operating System: ([A-Z]{1}[a-z]{1,}) ([A-Z]{1,3}?[a-z]{1,}? ?\/?[A-Z]{1}?[a-z]{1,}? ?[0-9]{1,2}\.?[0-9]{1,2}?).*/\1 \2/p' /tmp/distro.txt)

if [ "$DISTRO" = 'Debian GNU/Linux 12' -o "$DISTRO" = 'Ubuntu 24.04' ]; then
   echo "Your distribution is $DISTRO"
   echo -e 'Continuing...\n'
   sleep 3
   
   # Install expect
   echo -e 'Installing expect...\n'
   apt update && apt install -y expect
  
   # Install MariaDB
   echo 'Installing MariaDB...'
   sleep 3
   apt install -y mariadb-server mariadb-client
   sleep 3
   echo -e '\n'

elif [ "$DISTRO" = 'Rocky Linux 9.0' -o "$DISTRO" = 'Oracle Linux Server 9.4' ]; then
   echo "Your distribution is $DISTRO"
   echo -e 'Continuing...\n'
   sleep 2
   
   # Install expect
   echo 'Installing expect...'
   dnf install -y expect
   echo ' '

   # Install MariaDB
   echo 'Installing MariaDB...'
   dnf install -y mariadb-server
   sleep 1
   echo -e '\n'

else
   echo "Your distribution is $DISTRO"
   echo -e 'This distribution is not supported by this script.\n'
   echo 'The distributions supported are:'
   echo '- Debian GNU/Linux 12'
   echo '- Oracle Linux Server 9.4'
   echo '- Rocky Linux 9.0'
   echo -e '- Ubuntu 24.04\n'
   echo 'Aborting...'
   sleep 2
   exit 1
fi

# Enable and start MariaDB
echo 'Enabling MariaDB...'
sleep 3
systemctl enable mariadb
echo -e '\n'
sleep 3

echo 'Starting MariaDB...'
systemctl start mariadb
echo -e '\n'
sleep 3

# mysql_secure_installation
echo -e 'Configuring mysql_secure_installation...\n'
./MysqlSecure.exp
echo -e '\n\n'

# Create initial database and remote users
echo -e 'Creating inicial database and users...\n'
sleep 3
./ZabbixDBConfig.exp
echo -e '\n'

# Configure MariaDB for remote client access
echo 'Configuring MariaDB for remote client access...'
if [ "$DISTRO" = 'Debian GNU/Linux 12' -o "$DISTRO" = 'Ubuntu 24.04' ]; then
   # Edit bind-address in the file /etc/mysql/mariadb.conf.d/50-server.cnf
   echo 'Editing bind-address in the file /etc/mysql/mariadb.conf.d/50-server.cnf...'
   sed -ri 's/(bind-address            =) 127.0.0.1/\1 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
   echo ' '
else   
   # Open the firewall on Rocky Linux 9.0 or Oracle Linux 9.4
   echo 'Opening the firewall...'
   firewall-cmd --permanent --zone=public --add-port=3306/tcp
   firewall-cmd --reload
   echo ' '
fi   

# Restart mysql
echo 'Restarting mysql...'
systemctl restart mysql

echo ' '
echo -e 'End of script!\n'
