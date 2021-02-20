#!/bin/bash
sudo su
apt-get install -y curl
docker version > /dev/null || curl -fsSL get.docker.com | bash
service docker restart
sudo systemctl enable docker
docker pull teddysun/shadowsocks-r
mkdir -p /etc/shadowsocks-r
cat > /etc/shadowsocks-r/config.json <<EOF
{
    "server":"0.0.0.0",
    "server_ipv6":"::",
    "server_port":53333,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"qq3465141490",
    "timeout":120,
    "method":"none",
    "protocol":"auth_chain_a",
    "protocol_param":"",
    "obfs":"plain",
    "obfs_param":"",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":true,
    "workers":1
} 
EOF
docker run -d -p 53333:53333 -p 53333:53333/udp --name ssr --restart=always -v /etc/shadowsocks-r:/etc/shadowsocks-r teddysun/shadowsocks-r