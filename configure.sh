#!/bin/bash

yum install -y spamassassin mariadb mariadb-server cacti cyrus-imapd net-snmp-utils net-snmp nut

mkdir -p /var/lib/imap/sieve/d/dhill/
cp sieve/* /var/lib/imap/sieve/d/dhill/
chmod 755 /var/lib/imap/sieve/d/dhill/sieve

cp cyrus/* /etc/
systemctl enable cyrus-imapd
systemctl restart cyrus-imapd

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
