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

log_error                           = /var/lib/mysql/node${NODE_NR}.log


# # needed for innodb cluster
server_id                                 = $NODE_NR

# binlog_transaction_dependency_tracking  = WRITESET
# enforce_gtid_consistency                = ON
# gtid_mode                               = ON
# slave_parallel_type                     = LOGICAL_CLOCK
# slave_preserve_commit_order             = ON

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

mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'sekret';"
mysql -e "GRANT CLONE_ADMIN, CONNECTION_ADMIN, CREATE USER, EXECUTE, FILE, GROUP_REPLICATION_ADMIN, PERSIST_RO_VARIABLES_ADMIN, PROCESS, RELOAD, REPLICATION CLIENT, REPLICATION SLAVE, REPLICATION_APPLIER, REPLICATION_SLAVE_ADMIN, ROLE_ADMIN, SELECT, SHUTDOWN, SYSTEM_VARIABLES_ADMIN ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -e "GRANT DELETE, INSERT, UPDATE ON mysql.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -e "GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SHOW VIEW, TRIGGER, UPDATE ON mysql_innodb_cluster_metadata.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -e "GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SHOW VIEW, TRIGGER, UPDATE ON mysql_innodb_cluster_metadata_bkp.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -e "GRANT ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, EXECUTE, INDEX, INSERT, LOCK TABLES, REFERENCES, SHOW VIEW, TRIGGER, UPDATE ON mysql_innodb_cluster_metadata_previous.* TO 'admin'@'%' WITH GRANT OPTION;"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'sekret';"

tee /root/.my.cnf <<EOF
[client]
port                                = 3306
socket                              = /var/lib/mysql/mysql.sock
user                                = root
password                            = sekret

EOF
