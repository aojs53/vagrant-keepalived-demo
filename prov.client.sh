dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

dnf install -y lftp sshpass

mount /vagrant
cat /vagrant/hosts.vagrant >> /etc/hosts

## enable to ssh from client to all servers without ssh password.
cp /vagrant/.vagrant/machines/$(hostname)/virtualbox/private_key /home/vagrant/.ssh/id_rsa
head -1 /home/vagrant/.ssh/authorized_keys > /home/vagrant/.ssh/id_rsa.pub
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 600 /home/vagrant/.ssh/id_rsa.pub
chown vagrant:vagrant /home/vagrant/.ssh/*
SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
sudo -u vagrant sshpass -pvagrant ssh-copy-id $SSHOPTS vagrant@lvs1
sudo -u vagrant sshpass -pvagrant ssh-copy-id $SSHOPTS vagrant@lvs2
sudo -u vagrant sshpass -pvagrant ssh-copy-id $SSHOPTS vagrant@s1
sudo -u vagrant sshpass -pvagrant ssh-copy-id $SSHOPTS vagrant@s2

for h in s1 s2
do
  for i in /etc/ssh/ssh_host_*
  do
    cat $i | sudo -u vagrant ssh $SSHOPTS $h sudo tee $i
  done
done

for h in lvs1 lvs2 s1 s2
do
  sudo -u vagrant ssh -o StrictHostKeyChecking=no vagrant@$h hostname
done

