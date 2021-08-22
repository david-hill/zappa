echo "Changing zone for eno1"
nmcli c mod eno1 connection.zone external
echo "Changing zone for eno2"
nmcli c mod eno2 connection.zone internal
echo "Reloading firewall"
firewall-cmd --reload 
echo "Configure masquerade on external zone"
firewall-cmd --zone=external --add-masquerade --permanent 
echo "Reloading firewall"
firewall-cmd --reload 
echo "Configuring direct rules"
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o eno1 -j MASQUERADE 
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i eno2 -o eno1 -j ACCEPT 
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i eno1 -o eno2 -m state --state RELATED,ESTABLISHED -j ACCEPT 
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -o tun0 -m udp -p udp --dport 53 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -o tun0 -m tcp -p tcp --dport 53 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -m udp -p udp --dport 123 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -m tcp -p tcp --dport 123 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -o tun0 -m udp -p udp --dport 123 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -o tun0 -m tcp -p tcp --dport 123 -j ACCEPT
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -o tun0 -m tcp -p tcp --dport 80 -j ACCEPT 
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -m tcp -p tcp --dport 80 -j ACCEPT 
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -m tcp -p tcp --dport 623 -j ACCEPT 
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i virbr0 -m udp -p udp --dport 623 -j ACCEPT 
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -i eno1 -m udp -p udp --source 10.0.0.0/8 --dport 68 -j ACCEPT 
echo "Configuring external zone rules"
firewall-cmd --permanent --zone=external --add-forward-port=port=2235:proto=tcp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=26885:proto=tcp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=26885:proto=udp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=16946:proto=tcp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=2236:proto=tcp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=2235:proto=udp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=2236:proto=udp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=51413:proto=tcp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-forward-port=port=51413:proto=udp:toaddr=192.168.1.22
firewall-cmd --permanent --zone=external --add-port=113/tcp
firewall-cmd --permanent --zone=external --add-port=143/tcp
firewall-cmd --permanent --zone=external --add-port=993/tcp
firewall-cmd --permanent --zone=external --add-port=21/tcp
firewall-cmd --permanent --zone=external --add-port=22/tcp
echo "Configuring external zone rules"
firewall-cmd --permanent --zone=FedoraWorkstation --add-port=21/tcp
echo "Configuring internal zone rules"
firewall-cmd --permanent --zone=internal --add-port=8080/tcp
firewall-cmd --permanent --zone=internal --add-port=16509/tcp
firewall-cmd --permanent --zone=internal --add-port=143/tcp
firewall-cmd --permanent --zone=internal --add-port=993/tcp
firewall-cmd --permanent --zone=internal --add-port=5900-5920/tcp
firewall-cmd --permanent --zone=internal --add-port=22/tcp
firewall-cmd --permanent --zone=internal --add-port=25/tcp
firewall-cmd --permanent --zone=internal --add-port=67/tcp
firewall-cmd --permanent --zone=internal --add-port=67/udp
firewall-cmd --permanent --zone=internal --add-port=69/tcp
firewall-cmd --permanent --zone=internal --add-port=69/udp
firewall-cmd --permanent --zone=internal --add-port=53/tcp
firewall-cmd --permanent --zone=internal --add-port=53/udp
firewall-cmd --permanent --zone=internal --add-port=80/tcp
firewall-cmd --permanent --zone=internal --add-port=623/udp
firewall-cmd --permanent --zone=internal --add-port=623/tcp
firewall-cmd --permanent --zone=internal --add-port=123/udp
firewall-cmd --permanent --zone=internal --add-port=123/tcp

echo "Configuring libvir zone rules"
firewall-cmd --permanent --add-service=ntp --zone=libvirt
echo "Reloading firewall"
firewall-cmd --reload

echo "Enable logging of all denied packets"
firewall-cmd --set-log-denied=all
#firewall-cmd --set-log-denied=off

#iptables -I INPUT_direct -m udp -p udp -i virbr0 --dport 623 -j ACCEPT
#iptables -I INPUT_direct -m tcp -p tcp -i virbr0 --dport 623 -j ACCEPT
#iptables -I INPUT_direct -m tcp -p tcp -i virbr0 --dport 80 -j ACCEPT




systemctl restart firewalld 
