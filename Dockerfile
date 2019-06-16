# Dockerfile for shadowsocks-libev & privoxy based on alpine
# Copyright (C) 2018 - 2019 Zhaolj <zhaolj@gmail.com>
# Reference URL:
# https://github.com/zhaolj/shadowsocks_install/

FROM alpine:latest
MAINTAINER zhaolj <zhaolj@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV LIBEV_VER 3.2.5
ENV LIBEV_NAME shadowsocks-libev-${LIBEV_VER}
ENV LIBEV_RELEASE https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${LIBEV_VER}/${LIBEV_NAME}.tar.gz

RUN runDeps="\
        tar \
        git \
        wget \
        build-base \
        c-ares-dev \
        autoconf \
        automake \
        libev-dev \
        libtool \
        libsodium-dev \
        linux-headers \
        mbedtls-dev \
        pcre-dev \
    "; \
    set -ex \
    && apk add --no-cache --virtual .build-deps ${runDeps} \
    && mkdir -p /tmp/libev \
    && cd /tmp/libev \
    && git clone --depth=1 https://github.com/shadowsocks/simple-obfs.git . \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure --prefix=/usr --disable-documentation \
    && make install \
    && rm -rf * \
    && wget -qO ${LIBEV_NAME}.tar.gz ${LIBEV_RELEASE} \
    && tar zxf ${LIBEV_NAME}.tar.gz \
    && cd ${LIBEV_NAME} \
    && ./configure --prefix=/usr --disable-documentation \
    && make install \
    && apk add --no-cache rng-tools \
        $(scanelf --needed --nobanner /usr/bin/ss-* \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | xargs -r apk info --installed \
        | sort -u) \
    && apk del .build-deps \
    && cd /tmp \
    && rm -rf /tmp/libev


# ARG TZ='Asia/Shanghai'
# ARG SS_LIBEV_VERSION=v3.2.5
# ARG KCP_VERSION=20190611
# ARG SS_DOWNLOAD_URL=https://github.com/shadowsocks/shadowsocks-libev.git 
# ARG KCP_DOWNLOAD_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz
# ARG PLUGIN_OBFS_DOWNLOAD_URL=https://github.com/shadowsocks/simple-obfs.git
# ARG PLUGIN_V2RAY_DOWNLOAD_URL=https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.1.0/v2ray-plugin-linux-amd64-v1.1.0.tar.gz

# ENV TZ ${TZ}
# ENV SS_MODULE="ss-local"
# ENV SS_CONFIG="-c /etc/shadowsocks-libev/config.json"
# ENV KCP_FLAG="false"
# ENV KCP_MODULE="kcpclient"
# ENV KCP_CONFIG=""
# ENV PXY_FLAG="false"

# RUN echo "52.74.223.119    github.com" >> /etc/hosts
# RUN echo "151.101.229.194    github.global.ssl.fastly.net" >> /etc/hosts
# RUN echo "185.199.110.153    assets-cdn.github.com" >> /etc/hosts
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# RUN set -ex \
#     && apk update upgrade \
#     && apk add bash tzdata rng-tools runit privoxy \
#     && apk add --virtual .build-deps \
#         autoconf \
#         automake \
#         build-base \
#         curl \
#         wget \
#         c-ares-dev \
#         libev-dev \
#         libtool \
#         libsodium-dev \
#         mbedtls-dev \
#         pcre-dev \
#         tar \
#         git \
#         linux-headers \
#     && mkdir -p /tmp/libev \
#     && cd /tmp/libev \
#     && git clone ${SS_DOWNLOAD_URL} \
#     && (cd shadowsocks-libev \
#     && git checkout tags/${SS_LIBEV_VERSION} -b ${SS_LIBEV_VERSION} \
#     && git submodule update --init --recursive \
#     && ./autogen.sh \
#     && ./configure --prefix=/usr --disable-documentation \
#     && make install) \
#     && git clone ${PLUGIN_OBFS_DOWNLOAD_URL} \
#     && (cd simple-obfs \
#     && git submodule update --init --recursive \
#     && ./autogen.sh \
#     && ./configure --prefix=/usr --disable-documentation \
#     && make install) \
#     && curl -o v2ray_plugin.tar.gz -sSL ${PLUGIN_V2RAY_DOWNLOAD_URL} \
#     && tar -zxf v2ray_plugin.tar.gz \
#     && mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
#     && curl -sSLO ${KCP_DOWNLOAD_URL} \
#     && tar -zxf kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
#     && mv server_linux_amd64 /usr/bin/kcpserver \
#     && mv client_linux_amd64 /usr/bin/kcpclient \
#     && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
#     && echo ${TZ} > /etc/timezone \
#     && adduser -h /tmp -s /sbin/nologin -S -D -H shadowsocks \
#     && adduser -h /tmp -s /sbin/nologin -S -D -H kcptun \
#     && apk del .build-deps \
#     && apk add --no-cache \
#       $(scanelf --needed --nobanner /usr/bin/ss-* /usr/local/bin/obfs-* \
#       | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
#       | sort -u) \
#     && cd /tmp \
#     && rm -rf /tmp/libev \
#         /etc/service \
#         /etc/shadowsocks-libev \
#         /var/cache/apk/* 

# SHELL ["/bin/bash"]
ADD rootfs /
EXPOSE 8118 1080
VOLUME /etc/shadowsocks-libev
# USER nobody
# ENTRYPOINT ["/entrypoint.sh"]

CMD [ "ss-local", "-c", "/etc/shadowsocks-libev/config.json" ]
