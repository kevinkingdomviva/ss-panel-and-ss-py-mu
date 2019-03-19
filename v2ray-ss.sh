#!/bin/bash

# ===================================
# v2ray-ss.sh
# by DuanLian & pbstu
# https://www.pbstu.com/
# 2019.01.23
# ===================================

# 如果没有传入参数，或参数包含 --help ，打印脚本说明
if [[ ${#} == 0 ]] || [[ "${*}" == *--help* ]]; then
    echo -n "\
用法:
./v2ray-ss.sh [端口] [密码] [协议]

部署 v2ray
"
    exit 0
fi

# 传入参数处理
port="${1}"
password="${2}"
method="${3}"

# 获取最新稳定版本
var="$( curl -s "https://api.github.com/repos/v2ray/v2ray-core/releases/latest" | grep 'tag_name' | cut -d\" -f 4 )"

# 判断是否安装，以及是否更新
[[ -f "/usr/bin/v2ray/v2ray" ]] && [[ "$( /usr/bin/v2ray/v2ray -version | head -n 1 | cut -d ' ' -f 2 | tr -cd '[0-9]' )" == "$( echo "${var}" | tr -cd '[0-9]' )" ]] && { echo '已安装。'; exit 0; }
systemctl stop v2ray

# 回到 Home 目录
cd ~

# 安装依赖
command -v unzip >/dev/null 2>&1 || yum -y install unzip
command -v wget  >/dev/null 2>&1 || yum -y install wget

# 下载
wget -O 'v2ray.zip' "https://github.com/v2ray/v2ray-core/releases/download/${var}/v2ray-linux-64.zip"

# 解压
unzip -od v2ray v2ray.zip
rm -f v2ray.zip

# 复制文件
mkdir -p /usr/bin/v2ray
\cp v2ray/v2ray /usr/bin/v2ray/
\cp v2ray/v2ctl /usr/bin/v2ray/
chmod +x /usr/bin/v2ray/v2ray
chmod +x /usr/bin/v2ray/v2ctl
\cp v2ray/systemd/v2ray.service /etc/systemd/system/
rm -rf v2ray

# 生成配置文件
mkdir -p /var/log/v2ray
mkdir -p /etc/v2ray
cat >/etc/v2ray/config.json <<EOF
{
  "inbounds": [
    {
      "protocol": "shadowsocks",
      "port": ${port},
      "settings": {
        "password": "${password}",
        "method": "${method}",
        "network": "tcp,udp",
        "ota": false
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# 启动
systemctl enable v2ray
systemctl start v2ray
