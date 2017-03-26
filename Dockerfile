FROM alpine
ARG ENVIRONMENT_TYPE=PROD
COPY remove-busybox.sh /tmp/remove-busybox.sh
RUN apk update \
    && apk add --no-cache --virtual=.build-dependencies \
    musl-dev gcc linux-headers luarocks5.1 lua5.1-dev \
    && apk add --no-cache curl curl-dev luajit \
    && ln -s /usr/bin/luarocks-5.1 /usr/bin/luarocks \
    && luarocks install lua-cjson \
    && luarocks install Lua-cURL \
    && luarocks install basexx \
    && apk del --purge .build-dependencies \
    && /tmp/remove-busybox.sh \
    && rm /tmp/remove-busybox.sh
