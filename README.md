# shadowsocks-libev + privoxy

![](https://img.shields.io/docker/stars/zhaolj/shadowsocks-libev.svg) ![](https://img.shields.io/docker/pulls/zhaolj/shadowsocks-libev.svg) ![](https://img.shields.io/microbadger/image-size/zhaolj/shadowsocks-libev.svg) ![](https://img.shields.io/microbadger/layers/zhaolj/shadowsocks-libev.svg)

Shadowsocks-libev & privoxy Docker Image based on [mritd/shadowsocks](https://hub.docker.com/r/mritd/shadowsocks) & [gd41340811/shadowsocks-privoxy](https://hub.docker.com/r/gd41340811/shadowsocks-privoxy)

- **shadowsocks-libev version: 3.2.5**
- **kcptun version: 20190611**
- **privoxy version：3.0.26**
- **alpine version：latest**

### 打开姿势

``` sh
docker run -d --name ssclient -p 1080:1080 -p 8118:8118 \
    zhaolj/shadowsocks-libev:latest \
    -v /path/to/your/libev-config:/etc/shadowsocks-libev \
    -e SS_MODULE="ss-local" \
    -e SS_CONFIG="-c /etc/shadowsocks-libev/config.json" \
    -e PXY_FLAG="true"
    
```

注意：将`/path/to/your/libev-config`替换为宿主机上所包含`ss-local`所需的`config.json`配置文件的目录

### 环境变量支持

|环境变量|作用|取值|
|-------|---|---|
|SS_MODULE|shadowsocks 启动命令| `ss-local`、`ss-manager`、`ss-nat`、`ss-redir`、`ss-server`、`ss-tunnel`|
|SS_CONFIG|shadowsocks-libev 参数字符串|所有字符串内内容应当为 shadowsocks-libev 支持的选项参数|
|KCP_FLAG|是否开启 kcptun 支持|可选参数为 true 和 false，默认为 fasle 禁用 kcptun|
|KCP_MODULE|kcptun 启动命令| `kcpserver`、`kcpclient`|
|KCP_CONFIG|kcptun 参数字符串|所有字符串内内容应当为 kcptun 支持的选项参数|
|PXY_FLAG|是否开启 privoxy |可选参数为 true 和 false，默认为 fasle 禁用 privoxy|

### 命令示例

**Server 端**

``` sh
docker run -d --name ssserver -p 6443:6443 -p 6500:6500/udp \
    zhaolj/shadowsocks-libev:latest \
    -e SS_MODULE="ss-server" \
    -e SS_CONFIG="-s 0.0.0.0 -p 6443 -m chacha20-ietf-poly1305 -k test123" \
    -e KCP_FLAG="true" -e KCP_MODULE="kcpserver" \
    -e KCP_CONFIG="-t 127.0.0.1:6443 -l :6500 -mode fast2"
```

**以上命令相当于执行了**

``` sh
ss-server -s 0.0.0.0 -p 6443 -m chacha20-ietf-poly1305 -k test123
kcpserver -t 127.0.0.1:6443 -l :6500 -mode fast2
```

**Client 端**

``` sh
docker run -d --name ssclient -p 1080:1080 -p 8118:8118 \
    zhaolj/shadowsocks-libev:latest \
    -e SS_MODULE="ss-local" \
    -e SS_CONFIG="-s 127.0.0.1 -p 6500 -b 0.0.0.0 -l 1080 -m chacha20-ietf-poly1305 -k test123" \
    -e KCP_FLAG="true" -e KCP_MODULE="kcpclient" \
    -e KCP_CONFIG="-r SSSERVER_IP:6500 -l :6500 -mode fast2" \
    -e PXY_FLAG="true"
```

**以上命令相当于执行了** 

``` sh
ss-local -s 127.0.0.1 -p 6500 -b 0.0.0.0 -l 1080 -m chacha20-ietf-poly1305 -k test123
kcpclient -r SSSERVER_IP:6500 -l :6500 -mode fast2
privoxy /etc/privoxy/config
```

**关于 shadowsocks-libev 和 kcptun 都支持哪些参数请自行查阅官方文档，本镜像只做一个拼接**

**注意：kcptun 映射端口为 udp 模式(`6500:6500/udp`)，不写默认 tcp；shadowsocks 请监听 0.0.0.0**

`privoxy`仅在客户端模式下启动，即设置`-e SS_MODULE="ss-local"`，且`ss-local`监听的本地端口必须设置为1080（`SS_CONFIG`配置中有`"-l 1080"`，或config.json中设置`"local_port":1080,`）。

privoxy将监听8118端口的代理访问请求，所以必须docker容器需向外开放8118端口。


