#!/bin/bash

iptables -F
setenforce 0

cat <<EOF >/etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF

NODE_NR=$1
NODE_IP="$2"
MASTER_IP="$3"

# yum -y update

yum -y install wget libaio

yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

yum -y install mysql-community-server

yum -y install mysql-shell

tee /etc/my.cnf <<EOF
[mysql]
port                                = 3306
socket                              = /var/lib/mysql/mysql.sock
prompt                              = "node${NODE_NR}: \u@\h (\d) > "

[client]
port                                = 3306
socket                              = /var/lib/mysql/mysql.sock

[mysqld]
socket                              = /var/lib/mysql/mysql.sock
datadir                             = /var/lib/mysql
user                                = mysql

server_id                           = $NODE_NR

EOF

mysqld --initialize-insecure --user=mysql

systemctl start mysqld

mysql -e "CREATE USER 'monitor'@'%' IDENTIFIED BY 'monit0r';"
mysql -e "GRANT USAGE ON *.* TO 'monitor'@'%';"
mysql -e "CREATE USER 'monitor'@'localhost' IDENTIFIED BY 'monit0r';"
mysql -e "GRANT USAGE ON *.* TO 'monitor'@'localhost';"

mysql -e "CREATE USER 'app'@'%' IDENTIFIED BY 'app';"
mysql -e "GRANT ALL ON *.* TO 'app'@'%';"
mysql -e "CREATE USER 'app'@'localhost' IDENTIFIED BY 'app';"
mysql -e "GRANT ALL ON *.* TO 'app'@'localhost';"

mysql -e "CREATE DATABASE test;"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'sekret';"

tee /root/.my.cnf <<EOF
[client]
port                                = 3306
socket                              = /var/lib/mysql/mysql.sock
user																= root
password														= sekret

EOF
