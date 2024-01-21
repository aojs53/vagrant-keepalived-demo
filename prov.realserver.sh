VIP=192.168.56.100
NIC=enp0s8
MYIP=$(ip addr show dev $NIC | grep -w inet | perl -ne '/([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)/; print "$1.$2.$3.$4";')

## setup vsftpd
dnf install -y vsftpd
echo pasv_min_port=10000 >> /etc/vsftpd/vsftpd.conf
echo pasv_max_port=20000 >> /etc/vsftpd/vsftpd.conf
systemctl enable vsftpd --now

## setup nft for LVS to filter arp packet from realserver.
cat <<EOF > /etc/arpfilter.nft
table arp filter {
  chain OUTPUT {
    type filter hook output priority filter; policy accept;
    arp saddr ip $VIP arp saddr ip set $MYIP
  }
  chain INPUT {
    type filter hook input priority filter; policy accept;
    arp daddr ip $VIP drop
  }
}
EOF

cat << EOF > /etc/systemd/system/lvs-arpfilter.service 
[Unit]
Description=nft setting for lvs

[Service]
Type=oneshot
ExecStart=nft -f /etc/arpfilter.nft
 
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable lvs-arpfilter --now


## setup firewalld. need to be accessed by ftp.
systemctl enable firewalld --now
firewall-cmd --zone=public --add-service ftp
firewall-cmd --zone=public --add-port 21/tcp
firewall-cmd --zone=public --add-port 512-1024/tcp
firewall-cmd --zone=public --add-port 512-1024/udp
firewall-cmd --runtime-to-permanent


## setup /etc/hosts
mount /vagrant
cat /vagrant/hosts.vagrant >> /etc/hosts

## set vip and enable on boot.
echo ip addr add $VIP dev $NIC >> /etc/rc.local
chmod 755 /etc/rc.local
ip addr add $VIP dev $NIC

## ftp test file.
sudo -u vagrant dd if=/dev/zero of=/home/vagrant/10M.$(hostname) bs=1M count=10

