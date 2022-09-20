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

yum install -y spamassassin mariadb mariadb-server cacti cyrus-imapd net-snmp-utils net-snmp nut dhcp-server selinux-policy-devel gcc syslinux-tftpboot tftp-server tftp tuned lm_sensors python3-mysql python3-musicbrainzngs crash kernel-devel gettext-devel fail2ban oidentd
debuginfo-install cyrus-imapd libgcc kernel
debuginfo-install $( rpm -qR cyrus-imapd | awk '{ print $1 }' | grep -v rpmlib )

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
cp etc/yum.repos.d/* /etc/yum.repos.d
cp etc/sudoers.d/* /etc/sudoers.d/

cp etc/named.conf /etc/
cp etc/named/* /etc/named/named.conf
systemctl restart named

cp etc/firewalld/firewalld.conf /etc/firewalld
systemctl restart firewalld
firewall-cmd --reload

if [ ! -e /etc/pki/cyrus-imapd/cyrus-imapd.pem ]; then
  openssl req -new -x509 -nodes -config etc/pki/tls/openssl.cnf -out /etc/pki/cyrus-imapd/cyrus-imapd.pem -keyout /etc/pki/cyrus-imapd/cyrus-imapd.pem -days 825 -extensions extreq
fi

cp root/.ssh/* /root/.ssh/
chmod 600 /root/.ssh/authorized_keys

cp -pr /tftpboot/* /var/lib/tftpboot
cp var/lib/tftpboot/* /var/lib/tftpboot

wget http://techedemic.com/wp-content/uploads/2015/10/8-07-14_MegaCLI.zip
wget http://www.avagotech.com/docs-and-downloads/raid-controllers/raid-controllers-common-files/8-07-14_MegaCLI.zip

wget -nd -r --no-parent http://fedora.mirror.iweb.com/linux/development/rawhide/Everything/x86_64/os/isolinux/

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum install fontconfig java-11-openjdk
yum install jenkins

wget https://muug.ca/mirror/fedora/linux/releases/28/Workstation/x86_64/os/images/pxeboot/initrd.img
wget https://muug.ca/mirror/fedora/linux/releases/28/Workstation/x86_64/os/images/pxeboot/vmlinuz
mv initrd.img /var/lib/tftpboot/fedora
mv vmlinuz /var/lib/tftpboot/fedora
mkdir /var/lib/tftpboot/efi
cp /boot/efi/EFI/BOOT/BOOTX64.EFI /var/lib/tftpboot/efi

cp etc/postfix/* /etc/postfix
postmap /etc/postfix/header_checks
chown -R postfix /var/spool/postfix
chown -R postfix /var/spool/MailScanner
cp etc/ntpd.conf /etc
cp -pr etc/MailScanner/* /etc/MailScanner
cp -pr etc/mail/spamassassin/* /etc/mail/spamassassin/
cp etc/ssh/* /etc/ssh/
cp etc/sysconfig/* /etc/sysconfig/
cp etc/oidentd.conf /etc/
cp etc/ups/* /etc/ups
cp etc/hosts.deny /etc
cp etc/my.cnf /etc
cp etc/sysconfig/* /etc/sysconfig
cp etc/fail2ban/* /etc/fail2ban
cp -pr etc/fail2ban/action.d /etc/fail2ban/action.d
cp etc/dhcp/* /etc/dhcp
cp etc/gdm/* /etc/gdm
cp usr/share/selinux/devel/* /usr/share/selinux/devel
modules=$(find /usr/share/selinux/devel -name \*.pp)
for module in $(modules); do
  semodule -i $module
done

sed -i 's#secure_path = .*#secure_path = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin#' /etc/sudoers
cp usr/lib/systemd/system/* /usr/lib/systemd/system
systemctl daemon-reload
systemctl reset-failed

systemctl enable sshd.socket
systemctl start sshd.socket

systemctl restart sshd.service

mkdir -p /usr/src/kernels/linux-stable
cp kernel/* /usr/src/kernels/linux-stable

pip list | grep -q virtualbmc
if [ $? -ne 0 ]; then
  pip install virtualbmc
fi

mkdir /etc/virtualbmc
cp etc/virtualbmc /etc/virtualbmc

enable_start vbmcd
enable_start fail2ban
enable_start tftp
enable_start nut-server
enable_start cyrus-imapd
enable_start oidentd
enable_start postfix
disable_stop chronyd
disable_stop rngd
enable_start ntpd
enable_start mailscanner
enable_start named
enable_start dhcpd
enable_start tuned

tuned-adm profile balanced
