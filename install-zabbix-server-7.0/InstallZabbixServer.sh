#!/bin/bash

#----------------------------------------------------------------#
# Script name: Install Zabbix server                             #
# Description: Install and configure the Zabbix server frontend  #
# Author: Marco Antonio da Silva                                 #
# E-mail: marcoa.silva84@gmail.com                               #
# LinkedIn: https://www.linkedin.com/marcosilvarj                #
# Github: https://github.com/marcoantonio11                      #
# Use: ./InstallZabbixServer.sh                                  #
#----------------------------------------------------------------#

set -u
set -o pipefail 

ZABBIX_PASS=$(grep 'zabbix' ./variables | cut -d: -f2)
DB_IP=$(grep 'db-ip' ./variables | cut -d: -f2)

echo ' '
echo '##############################################################################'
echo '##### This script will install and configure the Zabbix server frontend ######'
echo '##############################################################################'
echo ' '

# Check if the admin knows the passwords
while true; do
echo '##############################################################################'
echo '## Do you know the passwords for the root and zabbix users of the database? ##'
echo '## You will need to use them!                                               ##'
echo '## (Y/N)?                                                                   ##'
echo '##############################################################################'
read -p "Chosen option: " ANSWER1

   case $ANSWER1 in
      [Y/y])
          echo -e 'Ok, lets continue...\n'
	  sleep 2
   break
          ;;
      [N/n])
	  echo 'The script is closing...'
	  sleep 2
	  exit 1
	  ;;
      *) 
          echo -e 'Invalid option! Try again.\n'
	  sleep 1
	  ;;
   esac
done

# Check if the database IP address and the zabbix user password were set
while true; do
   echo '##############################################################################'
   echo '## Before using this script:                                                ##'
   echo '## - Set the database IP address in the "variables" file.                   ##'
   echo '## - Set the zabbix user password in the "variables" file                   ##'
   echo '##                                                                          ##'
   echo '## Did you set the database IP address and the zabbix user password?        ##'
   echo '## (1) Yes, I set the database IP address and the zabbix user               ##'
   echo '##     password. Continue the script.                                       ##'
   echo '## (2) No, I did not set the database IP address or the zabbix user         ##'
   echo '##     password. Exit the script.                                           ##'
   echo '##############################################################################'
   read -p "Chosen option: " ANSWER2

   case $ANSWER2 in
      1)
          echo -e 'Ok, the script will continue...\n'
	  sleep 3
   break
          ;;
      2)
	  echo 'Ok, the script is closing...'
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

   if [ "$DISTRO" = 'Debian GNU/Linux 12' ]; then
     # Install Zabbix repository on Debian 12
      echo 'Installing Zabbix repository...'
      apt install wget -y
      wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
      dpkg -i zabbix-release_7.0-1+debian12_all.deb
      apt update
      echo ' '
      sleep 1
   else
      # Install Zabbix repository on Ubuntu 24.04
      echo 'Installing Zabbix repository...'
      apt install wget -y
      wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
      dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
      apt update
      echo ' '
      sleep 1
   fi

   #Install Zabbix server, frontend, agent on Debian 12 or Ubuntu 24.04
   echo 'Installing Zabbix server, frontend, agent...'
   apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
   echo ' '
   sleep 3

   # Remove installation file
   rm -f zabbix-release*

elif [ "$DISTRO" = 'Rocky Linux 9.0' -o "$DISTRO" = 'Oracle Linux Server 9.4' ]; then
   echo "Your distribution is $DISTRO"
   echo -e 'Continuing...\n'
   sleep 3

   # Check if the EPEL repository is enabled
   echo 'Checking if the EPEL repository is enabled...'
   if [ -f '/etc/yum.repos.d/epel.repo' ]; then
      echo 'The EPEL repository is enabled.'
      sleep 2
      echo 'Adding line "excludepkgs=zabbix*" in the file "/etc/yum.repos.d/epel.repo"...'
      sed -i '/excludepkgs=zabbix*'/d /etc/yum.repos.d/epel.repo
      sed -i '/\[epel\]/a\excludepkgs=zabbix*' /etc/yum.repos.d/epel.repo
      echo ' '
   else  
      echo 'The EPEl repository is not enabled.'
      echo -e 'Nothing to do.\n'
   fi

   # Install MariaDB client on Rocky Linux 9.0 or Oracle Linux 9.4
   echo 'Installing MariaDB client...'
   dnf install -y mariadb
   echo ' '
   
   if [ "$DISTRO" = 'Rocky Linux 9.0' ]; then
     # Install Zabbix repository on Rocky Linux 9.0
      echo 'Installing Zabbix repository...'
      rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rocky/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm
      dnf clean all
      echo ' '
      sleep 1
   else
      # Install Zabbix repository on Oracle Linux 9.4
      echo 'Installing Zabbix repository...'
      rpm -Uvh https://repo.zabbix.com/zabbix/7.0/oracle/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm
      dnf clean all
      echo ' '
      sleep 1
   fi

   # Install Zabbix server, frontend, agent on Rocky Linux 9.0 or Oracle Linux 9.4
   echo 'Installing Zabbix server, frontend, agent...'   
   dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent php php-devel
   echo ' '
   
   # Open the firewall on Rocky Linux 9.0 or Oracle Linux 9.4
   echo 'Openign the firewall...'
   firewall-cmd --permanent --zone=public --add-port=80/tcp
   firewall-cmd --permanent --zone=public --add-port=10051/tcp
   firewall-cmd --reload
   echo ' '

   # Open SELinux on Rocky Linux 9.0 or Oracle Linux 9.4
   echo 'Opening SELinux...'
   setsebool -P zabbix_can_network 1
   setsebool -P httpd_can_network_connect 1
   echo ' '

else
   echo "Your distribution is $DISTRO"
   echo -e 'This distribution is not supported by this script.\n'
   echo 'The distributions supported are:'
   echo '- Debian 12'
   echo '- Oracle Linux 9.4'
   echo '- Rocky Linux 9.0'
   echo -e 'Ubuntu 24.04'
   echo -e 'Aborting...\n'
   sleep 1
   exit 1
fi

#Importing initial schema and data
echo 'Importing initial schema and data...'
for X in {1..3}; do
   echo 'Enter the zabbix user password of the database.'
   zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -h $DB_IP -D zabbix -p |& tee /tmp/zabbix-err.txt
   if [ $? != 0 ]; then
      grep "already exists" /tmp/zabbix-err.txt > /dev/null
      if [ $? = 0 ]; then
	 echo 'WARN: This error means that this command has already been sucessfully executed previously.'
	 echo 'Continuing...'
         break	 
      else
         echo 'The password is incorrect or the database IP address is not set correctly in the "variables" file.'
         if [ $X -eq 1 ]; then
            echo -e 'You still have 2 tries.\n'
         elif [ $X -eq 2 ]; then
            echo -e 'You still have 1 try. In case of error the script will be closed.\n'
         else
            echo ' '
            echo -e 'The scrip is closing...\n'
	    sleep 1
	    exit 1
         fi
      fi
   else
   break
   fi
done
sleep 2

# Disable log_bin_trust_function_creators option after importing database schema.
echo ' '
echo 'Disabling log_bin_trust_function_creators option after importing database schema...'
for Y in {1..3}; do
   echo 'Enter the root user password of the database.'
   mysql -u root -p -h $DB_IP -e "set global log_bin_trust_function_creators = 0;"
   if [ $? != 0 ]; then
      echo 'Incorrect password! Try again.'
      if [ $Y -eq 1 ]; then
         echo -e 'You still have 2 tries.\n'
      elif [ $Y -eq 2 ]; then
         echo -e 'You still have 1 try. In case of error the script will be closed.\n'
      else
	 echo ' '
         echo -e 'The scrip is closing...\n'
	 sleep 1
	 exit 1
      fi
   else
      break
   fi
done
sleep 2

# Configure the database for the Zabbix server
# Edit DBPassword and DBHost in the file /etc/zabbix/zabbix_server.conf 
echo ' '
echo 'Configuring the database for the Zabbix server...'
sleep 1
echo 'Editing file /etc/zabbix/zabbix_server.conf...'
sed -ri "s/# (DBPassword=).*/\1$ZABBIX_PASS/" /etc/zabbix/zabbix_server.conf
sed -ri "s/# (DBHost=).*/\1$DB_IP/" /etc/zabbix/zabbix_server.conf
sleep 1

# Start Zabbix server and the agent proccesses
if [ "$DISTRO" = 'Debian GNU/Linux 12' -o "$DISTRO" = 'Ubuntu 24.04' ]; then
   # Enable and start Zabbix Server and agent proccesses on Debian 12 or Ubuntu 24.04
   echo ' '
   echo 'Enabling and staring Zabbix Server and agent proccesses...'
   systemctl restart zabbix-server zabbix-agent apache2
   systemctl enable zabbix-server zabbix-agent apache2
else
   # Enable and start Zabbix Server and agent proccesses on Rocky Linux 9.0 or Oracle Linux 9.4
   echo ' '
   echo 'Enabling and staring Zabbix Server and agent proccesses...'
   systemctl restart zabbix-server zabbix-agent httpd php-fpm
   systemctl enable zabbix-server zabbix-agent httpd php-fpm
fi

echo ' '
echo -e 'End of script.\n'
sleep 1

set +u
set +o pipefail 
