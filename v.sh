# !/bin/bash
# one key v2ray
rm -rf v2ray cloudflared-linux-amd64 v2ray-linux-64.zip
wget https://github.com/SagerNet/v2ray-core/releases/latest/download/v2ray-linux-64.zip
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
unzip -d v2ray v2ray-linux-64.zip
rm -rf v2ray-linux-64.zip
cat>v2ray/config.json<<EOF
{
	"inbounds": [
		{
			"port": 9999,
			"listen": "localhost",
			"protocol": "vmess",
			"settings": {
				"clients": [
					{
						"id": "1B8B9065-DC8A-4CCC-89C5-821CCC137442",
						"alterId": 0
					}
				],
				"disableInsecureEncryption": true
				},
			"streamSettings": {
				"network": "ws",
				"allowInsecure": false,
				"wsSettings": {
					"path": "/"
				}
			}
		}
	],
	"outbounds": [
	{
	"protocol": "freedom",
	"settings": {
	"domainStrategy": "UseIP"
	}
	}
	],
   "dns": {
        "servers": [
	"address": "https+local://dns.adguard.com/dns-query",
	"address": "https+local://1.1.1.1/dns-query",
	"address": "https+local://adblock.doh.mullvad.net/dns-query"
        ]
    }
}
EOF
kill -9 $(ps -ef | grep v2ray | grep -v grep | awk '{print $2}')
kill -9 $(ps -ef | grep cloudflared-linux-amd64 | grep -v grep | awk '{print $2}')
./v2ray/v2ray  run ./v2ray/config.json &
./cloudflared-linux-amd64 tunnel --url http://localhost:9999 --no-autoupdate>argo.log 2>&1 &
sleep 6
clear
echo 等到cloudflare argo生成地址
sleep 6
argo=$(cat argo.log | grep trycloudflare.com | awk 'NR==2{print}' | awk -F// '{print $2}' | awk '{print $1}')
clear
echo vmess链接已经生成,IP地址可替换为CF优选IP
echo 'vmess://'$(echo '{"add":"3.1.84.50","aid":"0","host":"'$argo'","id":"1B8B9065-DC8A-4CCC-89C5-821CCC137442","net":"ws","path":"/","port":"443","ps":"argo-co.id-vmess","tls":"tls","type":"none","v":"2"}' | base64 -w 0)
