FROM debian:stretch-slim

ARG PACKAGE_VERSION="=1.15.8-1sb"
ARG PACKAGE_REPO="https://mirrors.xtom.com/sb/nginx"

RUN deps='apt-transport-https gnupg1'; \
    set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates gettext-base $deps; \
    wget -qO- $PACKAGE_REPO/public.key | apt-key add -; \
    echo "deb $PACKAGE_REPO stretch nginx" > /etc/apt/sources.list.d/sb-nginx.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nginx$PACKAGE_VERSION; \
    apt-get purge -y --auto-remove $deps; \
    rm -rf /var/lib/apt/lists/*; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY docker-nginx-*.sh docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
