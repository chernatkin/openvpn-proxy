
sudo faillog -m 3 -l 3600

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install openvpn

wget -q https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.3/EasyRSA-3.0.3.tgz
tar -xzf EasyRSA-3.0.3.tgz
cd EasyRSA-3.0.3

./easyrsa init-pki
./easyrsa build-ca
./easyrsa build-server-full server nopass
./easyrsa build-client-full client nopass
./easyrsa gen-dh

sudo cp ./pki/dh.pem /etc/openvpn/dh.pem

sudo cp ./pki/private/client.key /etc/openvpn/

sudo cp ./pki/private/server.key /etc/openvpn/

sudo cp ./pki/ca.crt /etc/openvpn/

sudo cp ./pki/issued/client.crt /etc/openvpn/

sudo cp ./pki/issued/server.crt /etc/openvpn/


sudo mkdir /etc/openvpn/jail
sudo mkdir /etc/openvpn/jail/tmp

#add running on startup /etc/rc.local
sudo openvpn --config /etc/openvpn/server.conf

#sudo openvpn --config client.conf

#from client
ping 10.8.0.1
traceroute google.com

На сервере открываем файл /etc/sysctl.conf и раскомментируем в нем строчки:
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.ens3.accept_ra=2
Чтобы не пришлось перезагружаться, говорим:
echo 1 >> /proc/sys/net/ipv4/conf/all/forwarding

sudo iptables -t filter -A INPUT -i ens3 -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A INPUT -i ens3 -p tcp --dport 1194 -j ACCEPT
sudo iptables -t filter -A INPUT -i ens3 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t filter -A INPUT -i ens3 -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -t filter -A INPUT -i ens3 -p icmp --icmp-type echo-reply -j ACCEPT
sudo iptables -t filter -A INPUT -i ens3 -p udp -j ACCEPT
sudo iptables -t filter -A INPUT -i lo -j ACCEPT
sudo iptables -t filter -P INPUT DROP


sudo iptables -t filter -A FORWARD -s 10.8.0.0/24 -j ACCEPT
sudo iptables -t filter -A FORWARD -d 10.8.0.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t filter -P FORWARD DROP

sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source <server_ip>


# ipv6
sudo ip6tables -t filter -A INPUT -i ens3 -p tcp --dport 22 -j ACCEPT
sudo ip6tables -t filter -A INPUT -i ens3 -p tcp --dport 1194 -j ACCEPT
sudo ip6tables -t filter -A INPUT -i ens3 -p tcp -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip6tables -t filter -A INPUT -i ens3 -p icmpv6 -j ACCEPT
sudo ip6tables -t filter -A INPUT -i ens3 -p udp -j ACCEPT
sudo ip6tables -t filter -A INPUT -i lo -j ACCEPT
sudo ip6tables -t filter -P INPUT DROP

sudo ip6tables -t filter -P FORWARD DROP

sudo apt-get install iptables-persistent
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6




