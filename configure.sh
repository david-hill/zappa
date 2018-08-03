#!/bin/bash

function disable_stop {
  s=$1
  systemctl status $s | grep -q enabled
  if [ $? -eq 0 ]; then
    systemctl disable $s
  fi
  systemctl status $s | grep -q running
  if [ $? -ne 0 ]; then
    systemctl stop $s
  fi
}

function enable_start {
  s=$1
  systemctl status $s | grep -q enabled
  if [ $? -ne 0 ]; then
    systemctl enable $s
  fi
  systemctl status $s | grep -q running
  if [ $? -ne 0 ]; then
    systemctl start $s
  fi
}

yum install -y spamassassin mariadb mariadb-server cacti cyrus-imapd net-snmp-utils net-snmp nut dhcp-server selinux-policy-devel gcc syslinux-tftpboot tftp-server

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
cp var/lib/imap/sieve/d/dhill/* /var/lib/imap/sieve/d/dhill/
chmod 755 /var/lib/imap/sieve/d/dhill/sieve

cp etc/imapd.conf /etc/
cp etc/cyrus.conf /etc/

if [ ! -e /etc/pki/cyrus-imapd/cyrus-imapd.pem ]; then
  openssl req -new -x509 -nodes -out /etc/pki/cyrus-imapd/cyrus-imapd.pem -keyout /etc/pki/cyrus-imapd/cyrus-imapd.pem -days 3650
fi

cp root/.ssh/* /root/.ssh/
chmod 600 /root/.ssh/authorized_keys

cp etc/postfix/* /etc/postfix
postmap /etc/postfix/header_checks
cp etc/ntpd.conf /etc
cp -pr etc/MailScanner/* /etc/MailScanner
cp -pr etc/mail/spamassassin/* /etc/mail/spamassassin/
cp etc/ups/* /etc/ups
cp etc/my.cnf /etc
cp etc/sysconfig/* /etc/sysconfig
cp etc/dhcp/* /etc/dhcp
cp usr/share/selinux/devel/* /usr/share/selinux/devel
modules=$(find /usr/share/selinux/devel -name \*.pp)
for module in $(modules); do
  semodule -i $module
done

cp usr/lib/systemd/system/* /usr/lib/systemd/system
systemctl daemon-reload
systemctl reset-failed

mkdir -p /usr/src/kernels/linux-stable
cp kernel/* /usr/src/kernels/linux-stable

enable_start tftp
enable_start nut-server
enable_start cyrus-imapd
enable_start postfix
disable_stop chronyd
disable_stop rngd
enable_start ntpd
enable_start mailscanner
enable_start named
enable_start dhcpd
