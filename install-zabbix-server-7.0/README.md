# Install Zabbix Server 7.0

This project performs the installation and configuration of the Zabbix Server database and frontend 7.0 on the folowing distributions using Shell Script.

- Debian 12
- Oracle Linux 9.4
- Rocky Linux 9.0
- Ubuntu 24.04
## Documentation

This project is divided in two parts. First run the InstallZabbixDatabase.sh script on the database instance and then run the InstallZabbixServer.sh script on the frontend instance.

Note: For security reason, it's recommended to protect the variables file using the command below:

$ chmod 600 variables

Step 1

Run InstallZabbixDatabase.sh. This script:

- Install MariaDB, enable and start the service;
- Configure mysql_secure_installation;
- Create the Zabbix database and the local and remote database users;
- Configure the bind address to allow remote connections on Debian 12 and Ubuntu 24.04;
- Open the firewall on Oracle Linux 9.4 and Rocky Linux 9.0;

Warn: Before running this script it's necessary to set the root and zabbix user passwords and the IP address for remote access in the variables file. You will be reminded of this when you run it.

Step 2

Run InstallZabbixServer.sh. This script:

- Block download of Zabbix packages from the EPEL repository if it is avtive on Oracle Linux 9.4 and Rocky Linux 9.0;
- Install Zabbix repository;
- Install Zabbix server, frontend, agent;
- Install MariaDB client on Oracle Linux 9.4 and Rocky Linux 9.0;
- Open the firewall and SELinux on Oracle Linux 9.4 and Rocky Linux 9.0;
- Import initial schema and data;
- Disabe log_bin_trust_function_creators;
- Edit DBHost and DBPassword in the /etc/zabbix/zabbix_server.conf file;
- Enable and start the services.

Warn: 
Before running this script you will need to know the passwords for the root and zabbix users. You will also need to set the database IP and zabbix user password in the variables file. You will be reminded of this when you run it.


## Author

Marco Antonio da Silva

- [Github](https://github.com/marcoantonio11)
- [LinkedIn](https://www.linkedin.com/in/marcosilvarj)

## Feedback

If you have any feedback, please let me know at marcoa.silva84@gmail.com


## License

[MIT](https://choosealicense.com/licenses/mit/)

