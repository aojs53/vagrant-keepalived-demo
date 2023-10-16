PRIMARY="lvs1"
SECONDARY="lvs2"
VIP=192.168.56.100

## disable selinux
sed -ie 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config

## tweak kernel parameter for lvs.
sysctl -w net.ipv4.ip_forward=1 > /etc/sysctl.d/90-lvs.conf

## prerquired packages
dnf install -y keepalived ipvsadm mailx mutt postfix tcpdump

## startup postfix
systemctl enable postfix --now

## setup keepalived
mount /vagrant
h=$(hostname)
if [ "$h" = ${PRIMARY} ];
then
  cp /vagrant/keepalived.conf.primary /etc/keepalived/keepalived.conf
elif [ "$h" = ${SECONDARY} ];
then
  cp /vagrant/keepalived.conf.secondary /etc/keepalived/keepalived.conf
else
  echo "unknown hostname detected. exit."
  exit 1
fi
systemctl enable keepalived --now

## setup firewall
systemctl enable firewalld --now
firewall-cmd --direct --add-rule ipv4 mangle PREROUTING 0 -d $VIP -p tcp -m tcp --dport 20:21 -j MARK --set-mark 21
firewall-cmd --direct --add-rule ipv4 mangle PREROUTING 1 -d $VIP -p tcp -m tcp --dport 10000:20000 -j MARK --set-mark 21
firewall-cmd --zone public --add-port 0-65535/udp
firewall-cmd --zone public --add-port 0-65535/tcp
firewall-cmd --zone public --add-rich-rule='rule protocol value=vrrp accept'
firewall-cmd --runtime-to-permanent


## tweak /etc/hosts
cat /vagrant/hosts.vagrant >> /etc/hosts
