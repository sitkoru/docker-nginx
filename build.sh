#!/bin/sh
set -eu

cd /usr/src

curl -fsSL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -o nginx.tar.gz
echo '2565b5c837050e958f70fb0f73c48e2bca4542ad349fd356f46fb0c72610bc6e  nginx.tar.gz' | sha256sum -c -
mkdir nginx
tar -xzf nginx.tar.gz --strip-components=1 -C nginx

curl -fsSL https://codeload.github.com/google/ngx_brotli/tar.gz/53e0fb55f250f48fe80c0ddbf6c0f7103cdbaae1 -o brotli.tar.gz
echo '27a4352dae4ba4922f9f013f3f0d02359aceeef2701872efa42849c3ba05457a  brotli.tar.gz' | sha256sum -c -
mkdir brotli
tar -xzf brotli.tar.gz --strip-components=1 -C brotli
# Compile against Debian's Brotli headers and link to its libbrotli1.
mkdir -p brotli/deps/brotli/c
ln -s /usr/include brotli/deps/brotli/c/include

curl -fsSL https://codeload.github.com/vozlt/nginx-module-vts/tar.gz/refs/tags/v0.2.7 -o vts.tar.gz
echo '0003bfa57da2106367fdc3f87760910c046e7df5545db73c880fc2b80350b14c  vts.tar.gz' | sha256sum -c -
mkdir vts
tar -xzf vts.tar.gz --strip-components=1 -C vts

cd nginx
./configure --with-compat --with-http_ssl_module --with-http_v2_module --with-http_v3_module \
    --add-dynamic-module=../brotli --add-dynamic-module=../vts
make -j2 modules
