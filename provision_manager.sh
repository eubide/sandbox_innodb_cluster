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

# yum -y install mysql-community-server

yum -y install mysql-community-client

yum -y install mysql-shell

yum -y install mysql-router
