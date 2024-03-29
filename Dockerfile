FROM nginx:1.24.0 as build

ENV CODENAME bullseye
ENV NGINX_VERSION 1.24.0

RUN apt-get update \
    && apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget libcurl4-openssl-dev libjansson-dev uuid-dev libbrotli-dev git

RUN wget http://nginx.org/keys/nginx_signing.key \
    && apt-key add nginx_signing.key \
    && echo "deb http://nginx.org/packages/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get build-dep -y nginx=${NGINX_VERSION}-1

WORKDIR /nginx

ENV NPSOL_VERSION focal
ENV OSSL_VERSION 1.1.1g
ENV VTS_VERSION=0.1.18

ADD ./build.sh build.sh

RUN chmod a+x ./build.sh && ./build.sh
RUN apt-get download libbrotli1


FROM nginx:1.24.0 as publish
COPY --from=build /nginx/nginx_1.24.0-1~bullseye_amd64.deb /nginx/libbrotli1*.deb /_pkgs/
RUN dpkg --install /_pkgs/*.deb && rm -rf /_pkgs
