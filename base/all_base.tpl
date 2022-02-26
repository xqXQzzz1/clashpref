# Clash & ClashR
# 从 配置文件 中获取，判断前缀为 global
# 从 外部配置 中获取，判断前缀为 local
# 从 URL 链接中获取，判断前缀为 request，例如 http://127.0.0.1:25500/sub?target=clash&url=www.xxx.com&clash.dns=1
{% if request.target == "clash" or request.target == "clashr" %}

mixed-port: {{ local.clash.mixed_port }}
allow-lan: {{ local.clash.allow_lan }}
mode: rule
log-level: {{ default(request.loglevel , "debug") }}
external-controller: 127.0.0.1:9090
profile:
  # Store the `select` results in $HOME/.config/clash/.cache
  # set false If you don't want this behavior
  # when two different configurations have groups with the same name, the selected values are shared
  store-selected: true

  # persistence fakeip
  store-fake-ip: true

# 实验性功能
experimental:
  ignore-resolve-fail: true # 忽略 DNS 解析失败，默认值为 true
# interface-name: clash-tap # outbound interface name

# Clash DoH

{% if default(request.dns, "true") == "true" %}

dns:
  enable: true # 是否启用dns false
  ipv6: true
  listen: 0.0.0.0:53
  # 以下填写的 DNS 服务器将会被用来解析 DNS 服务的域名
  # 仅填写 DNS 服务器的 IP 地址
  # default-nameserver:
  #   - 114.114.114.114
  #   - 223.5.5.5
  enhanced-mode: fake-ip # 模式：redir-host或fake-ip
  fake-ip-range: 198.18.0.1/16 # Fake IP addresses pool CIDR
  fake-ip-filter: # fake ip 白名单列表，如果你不知道这个参数的作用，请勿修改
    # 以下域名列表参考自 vernesong/OpenClash 项目，并由 Hackl0us 整理补充
    # === LAN ===
    - "*.lan"
    # === Linksys Wireless Router ===
    - "*.linksys.com"
    - "*.linksyssmartwifi.com"
    # === Apple Software Update Service ===
    - "swscan.apple.com"
    - "mesu.apple.com"
    # === Windows 10 Connnect Detection ===
    - "*.msftconnecttest.com"
    - "*.msftncsi.com"
    # === NTP Service ===
    - "time.*.com"
    - "time.*.gov"
    - "time.*.edu.cn"
    - "time.*.apple.com"

    - "time1.*.com"
    - "time2.*.com"
    - "time3.*.com"
    - "time4.*.com"
    - "time5.*.com"
    - "time6.*.com"
    - "time7.*.com"

    - "ntp.*.com"
    - "ntp.*.com"
    - "ntp1.*.com"
    - "ntp2.*.com"
    - "ntp3.*.com"
    - "ntp4.*.com"
    - "ntp5.*.com"
    - "ntp6.*.com"
    - "ntp7.*.com"

    - "*.time.edu.cn"
    - "*.ntp.org.cn"
    - "+.pool.ntp.org"

    - "time1.cloud.tencent.com"
    # === Music Service ===
    ## NetEase
    - "+.music.163.com"
    - "*.126.net"
    ## Baidu
    - "musicapi.taihe.com"
    - "music.taihe.com"
    ## Kugou
    - "songsearch.kugou.com"
    - "trackercdn.kugou.com"
    ## Kuwo
    - "*.kuwo.cn"
    ## JOOX
    - "api-jooxtt.sanook.com"
    - "api.joox.com"
    - "joox.com"
    ## QQ
    - "+.y.qq.com"
    - "+.music.tc.qq.com"
    - "aqqmusic.tc.qq.com"
    - "+.stream.qqmusic.qq.com"
    ## Xiami
    - "*.xiami.com"
    ## Migu
    - "+.music.migu.cn"
    # === Game Service ===
    ## Nintendo Switch
    - "+.srv.nintendo.net"
    ## Sony PlayStation
    - "+.stun.playstation.net"
    ## Microsoft Xbox
    - "xbox.*.microsoft.com"
    - "+.xboxlive.com"
    # === Other ===
    ## QQ Quick Login
    - "localhost.ptlogin2.qq.com"
    ## Golang
    - "proxy.golang.org"
    ## STUN Server
    - "stun.*.*"
    - "stun.*.*.*"
  nameserver:
    - dhcp://en0 # dns from dhcp
    - 223.5.5.5 # 阿里DNS
    # - 180.76.76.76 # 百度DNS
    - 119.29.29.29 # 腾讯DNS
    # - 117.50.10.10 # ONE DNS纯净版 直接返回其真实的响应结果
    - 114.114.114.114 # 114DNS
    - 43.226.158.91:777
    # - https://i.passcloud.xyz/dns-query
    # - https://sm2.doh.pub/dns-query #腾讯
    # - https://dns.alidns.com/dns-query # 阿里 DoH DNS
    # - https://doh.360.cn/dns-query # 360 DoH DNS
  fallback:
    # - 1.1.1.1
    # - 8.8.8.8 # 谷歌DNS
    # - tls://dns.rubyfish.cn:853
    # - tls://1.0.0.1:853
    - tls://dns.google:853
    # - https://dns.rubyfish.cn/dns-query
    # - https://cloudflare-dns.com/dns-query
    # - https://dns.google/dns-query
    - https://i.passcloud.xyz/dns-query
    - https://sm2.doh.pub/dns-query #腾讯
  fallback-filter:
    geoip: true # 默认
    geoip-code: CN
    # ipcidr: # 在这个网段内的 IP 地址会被考虑为被污染的 IP
    #   - 240.0.0.0/4
    domain:
      # - '+.google.com'
      # - '+.facebook.com'
      # - '+.youtube.com'
      - '+.nfmovies.com'
# 1. clash DNS 请求逻辑：
#   (1) 当访问一个域名时， nameserver 与 fallback 列表内的所有服务器并发请求，得到域名对应的 IP 地址。
#   (2) clash 将选取 nameserver 列表内，解析最快的结果。
#   (3) 若解析结果中，IP 地址属于 国外，那么 clash 将选择 fallback 列表内，解析最快的结果。
#
#   因此，我在 nameserver 和 fallback 内都放置了无污染、解析速度较快的国内 DNS 服务器，以达到最快的解析速度。
#   但是 fallback 列表内服务器会用在解析境外网站，为了结果绝对无污染，我仅保留了支持 DoT/DoH 的两个服务器。
#
# 2. clash DNS 配置注意事项：
#   (1) 如果您为了确保 DNS 解析结果无污染，请仅保留列表内以 tls:// 或 https:// 开头的 DNS 服务器，但是通常对于国内域名没有必要。
#   (2) 如果您不在乎可能解析到污染的结果，更加追求速度。请将 nameserver 列表的服务器插入至 fallback 列表内，并移除重复项。
#
# 3. 关于 DNS over HTTPS (DoH) 和 DNS over TLS (DoT) 的选择：
#   对于两项技术双方各执一词，而且会无休止的争论，各有利弊。各位请根据具体需求自行选择，但是配置文件内默认启用 DoT，因为目前国内没有封锁或管制。
#   DoH: 以 https:// 开头的 DNS 服务器。拥有更好的伪装性，且几乎不可能被运营商或网络管理封锁，但查询效率和安全性可能略低。
#   DoT: 以 tls:// 开头的 DNS 服务器。拥有更高的安全性和查询效率，但端口有可能被管制或封锁。
#   若要了解更多关于 DoH/DoT 相关技术，请自行查阅规范文档。
{% if default(request.tun, "fasle") == "true" %}
tun:
  enable: true
{% if default(request.deviceinfo, "windows") == windows %}
  stack: gvisor #system # or gvisor
{% else %}
  stack: system #system # or gvisor
{% endif %}
  dns-hijack:
    - 198.18.0.2:53 # when `fake-ip-range` is 198.18.0.1/16, should hijack 198.18.0.2:53
  auto-route: true # auto set global route for Windows
  # It is recommended to use `interface-name`
  auto-detect-interface: true # auto detect interface, conflict with `interface-name`
{% endif %}
{% endif %}




{% if default(request.clashnewfiled, "true") == "true" %}
proxies: ~
proxy-groups: ~
rules: ~
{% else %}
Proxy: ~
Proxy Group: ~
Rule: ~
{% endif %}

{% endif %}

# Clash & ClashR End

{% if request.target == "surge" %}
[General]
loglevel = notify
bypass-system = true
skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local, e.crashlytics.com, captive.apple.com, ::ffff:0:0:0:0/1, ::ffff:128:0:0:0/1
#DNS设置或根据自己网络情况进行相应设置
bypass-tun = 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12
dns-server = 119.29.29.29, 223.5.5.5, 1.1.1.1, 8.8.8.8
{% if default(request.surge.doh, "") == "true" %}
doh-format = wireformat
doh-server = https://dns.alidns.com/dns-query
{% endif %}
[Script]

{% endif %}
{% if request.target == "loon" %}

[General]
skip-proxy = 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,localhost,*.local,e.crashlynatics.com
bypass-tun = 10.0.0.0/8,100.64.0.0/10,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.0.0.0/24,192.0.2.0/24,192.88.99.0/24,192.168.0.0/16,198.18.0.0/15,198.51.100.0/24,203.0.113.0/24,224.0.0.0/4,255.255.255.255/32
dns-server = system,119.29.29.29,223.5.5.5
allow-udp-proxy = false
host = 127.0.0.1

[Proxy]

[Remote Proxy]

[Proxy Group]

[Rule]

[Remote Rule]

[URL Rewrite]
enable = true
^https?:\/\/(www.)?(g|google)\.cn https://www.google.com 302

[Remote Rewrite]
https://raw.githubusercontent.com/Loon0x00/LoonExampleConfig/master/Rewrite/AutoRewrite_Example.list,auto

[MITM]
hostname = *.example.com,*.sample.com
enable = true
skip-server-cert-verify = true
#ca-p12 =
#ca-passphrase =

{% endif %}
{% if request.target == "quan" %}

[SERVER]

[SOURCE]

[BACKUP-SERVER]

[SUSPEND-SSID]

[POLICY]

[DNS]
1.1.1.1

[REWRITE]

[URL-REJECTION]

[TCP]

[local]

[HOST]

[STATE]
STATE,AUTO

[MITM]

{% endif %}
{% if request.target == "quanx" %}

[general]
excluded_routes=192.168.0.0/16, 172.16.0.0/12, 100.64.0.0/10, 10.0.0.0/8
geo_location_checker=http://ip-api.com/json/?lang=zh-CN, https://github.com/KOP-XIAO/QuantumultX/raw/master/Scripts/IP_API.js
network_check_url=http://www.baidu.com/
server_check_url=http://www.gstatic.com/generate_204

[dns]
server=119.29.29.29
server=223.5.5.5
server=1.0.0.1
server=8.8.8.8

[policy]
static=♻️ 自动选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Auto.png
static=🔰 节点选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Proxy.png
static=🌍 国外媒体, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/localMedia.png
static=🌏 国内媒体, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/DomesticMedia.png
static=Ⓜ️ 微软服务, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Microsoft.png
static=📲 电报信息, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Telegram.png
static=🍎 苹果服务, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Apple.png
static=🎯 全球直连, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Direct.png
static=🛑 全球拦截, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Advertising.png
static=🐟 漏网之鱼, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Final.png

[server_remote]

[filter_remote]

[rewrite_remote]

[server_local]

[filter_local]

[rewrite_local]

[mitm]

{% endif %}
{% if request.target == "mellow" %}

[Endpoint]
DIRECT, builtin, freedom, domainStrategy=UseIP
REJECT, builtin, blackhole
Dns-Out, builtin, dns

[Routing]
domainStrategy = IPIfNonMatch

[Dns]
hijack = Dns-Out
clientIp = 114.114.114.114

[DnsServer]
localhost
223.5.5.5
8.8.8.8, 53, Remote
8.8.4.4

[DnsRule]
DOMAIN-KEYWORD, geosite:geolocation-!cn, Remote
DOMAIN-SUFFIX, google.com, Remote

[DnsHost]
doubleclick.net = 127.0.0.1

[Log]
loglevel = warning

{% endif %}
{% if request.target == "surfboard" %}

[General]
loglevel = notify
interface = 127.0.0.1
skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
ipv6 = false
dns-server = system, 223.5.5.5
exclude-simple-hostnames = true
enhanced-mode-by-rule = true
{% endif %}
{% if request.target == "sssub" %}
{
  "route": "bypass-lan-china",
  "remote_dns": "dns.google",
  "ipv6": false,
  "metered": false,
  "proxy_apps": {
    "enabled": false,
    "bypass": true,
    "android_list": [
      "com.eg.android.AlipayGphone",
      "com.wudaokou.hippo",
      "com.zhihu.android"
    ]
  },
  "udpdns": false
}

{% endif %}
