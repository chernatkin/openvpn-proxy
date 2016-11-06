
sudo apt-get install openvpn

wget -q https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz
tar -xzf EasyRSA-3.0.1.tgz
cd EasyRSA-3.0.1

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


#add running on startup /etc/rc.local
sudo openvpn --config /etc/openvpn/server.conf

#sudo openvpn --config client.conf

#from client
ping 10.128.0.1
traceroute mail.ru

На сервере открываем файл /etc/sysctl.conf и раскомментируем в нем строчку:
net.ipv4.ip_forward=1
Чтобы не пришлось перезагружаться, говорим:
echo 1 >> /proc/sys/net/ipv4/conf/all/forwarding

sudo iptables -t filter -A INPUT -p tcp --dport 1194 -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.128.0.0/24 -j ACCEPT
sudo iptables -t filter -A FORWARD -d 10.128.0.0/24 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.128.0.0/24 -j SNAT --to-source <server_ip>

sudo iptables-save > /etc/iptables.rules
sudo cp iptablesload /etc/network/if-pre-up.d/
sudo chmod +x /etc/network/if-pre-up.d/iptablesload

