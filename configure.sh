#!/bin/bash

yum install -y spamassassin mariadb mariadb-server cacti cyrus-imapd net-snmp-utils net-snmp nut dhcp-server selinux-policy-devel gcc

wget https://www.dcc-servers.net/dcc/source/dcc.tar.Z
tar xvf dcc.tar.Z
cd dcc-1.3.159
./configure
make
make install
cd ..
rm -rf dcc.tar.Z
rm -rf dcc-1.3.159

mkdir -p /var/lib/imap/sieve/d/dhill/
cp sieve/* /var/lib/imap/sieve/d/dhill/
chmod 755 /var/lib/imap/sieve/d/dhill/sieve

cp cyrus/* /etc/
systemctl enable cyrus-imapd
systemctl restart cyrus-imapd

openssl req -new -x509 -nodes -out /etc/pki/cyrus-imapd/cyrus-imapd.pem -keyout /etc/pki/cyrus-imapd/cyrus-imapd.pem -days 3650

cp ssh/* /root/.ssh/
chmod 600 /root/.ssh/authorized_keys

cp postfix/* /etc/postfix
postmap /etc/postfix/header_checks
systemctl enable postfix
systemctl restart postfix


cp -pr mailscanner/* /etc/MailScanner
cp -pr mail/* /etc/mail/spamassassin/
systemctl enable mailscanner
systemctl restart mailscanner

cp ups/* /etc/ups
systemctl enable nut-server
systemctl restart nut-server

systemctl enable named
systemctl restart named

cp mysql/my.cnf /etc
systemctl restart mariadb

cp sysconfig/* /etc/sysconfig
systemctl restart named

cp dhcp/dhcpd/* /etc/dhcp
systemctl enable dhcpd
systemctl restart dhcpd

cp selinux/* /usr/share/selinux/devel
modules=$(find /usr/share/selinux/devel -name \*.pp)
for module in $(modules); do
  semodule -i $module
done

cp usr/lib/systemd/system/* /usr/lib/systemd/system
systemctl daemon-reload

systemctl disable rngd.service

systemctl reset-failed
