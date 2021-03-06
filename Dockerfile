FROM nginx:1.19.3

ENV NGINX_VERSION 1.19.3
ENV NPS_VERSION 36
ENV NPSOL_VERSION 1.13.35.2-stable
ENV OSSL_VERSION 1.1.1g
ENV CODENAME buster
ENV VTS_VERSION=0.1.18

RUN apt-get update \
    && apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget libcurl4-openssl-dev libjansson-dev uuid-dev libbrotli-dev

RUN wget http://nginx.org/keys/nginx_signing.key \
    && apt-key add nginx_signing.key \
    && echo "deb http://nginx.org/packages/mainline/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get build-dep -y nginx=${NGINX_VERSION}-1

WORKDIR /nginx

ADD ./build.sh build.sh

RUN chmod a+x ./build.sh && ./build.sh
RUN apt-get download libbrotli1


FROM nginx:1.19.3
COPY --from=0 /nginx/nginx_1.19.3-1~buster_amd64.deb /nginx/libbrotli1*.deb /_pkgs/
RUN dpkg --install /_pkgs/*.deb && rm -rf /_pkgs
