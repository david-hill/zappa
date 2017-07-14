#!/bin/bash

mkdir -p /var/lib/imap/sieve/d/dhill/
cp sieve/* /var/lib/imap/sieve/d/dhill/
chmod 755 /var/lib/imap/sieve/d/dhill/sieve

cp cyrus/* /etc/
systemctl restart cyrus-imapd

cp ssh/* /root/.ssh/
chmod 600 /root/.ssh/authorized_keys

cp postfix/* /etc/postfix
postmap /etc/postfix/header_checks

cp mailscanner /etc/MailScanner
systemctl restart mailscanner
