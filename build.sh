#!/bin/bash
mkdir -p /nginx
cd /nginx
apt-get source nginx=${NGINX_VERSION}-1
mkdir -p nginx-${NGINX_VERSION}/debian/modules
cd nginx-${NGINX_VERSION}/debian/modules

wget https://github.com/apache/incubator-pagespeed-ngx/archive/${NPS_VERSION}.zip -O release-${NPS_VERSION}.zip
unzip release-${NPS_VERSION}.zip
cd incubator-pagespeed-ngx-${NPS_VERSION}/
psol_url=https://dl.google.com/dl/page-speed/psol/${NPSOL_VERSION}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})

cd /nginx/nginx-${NGINX_VERSION}
wget https://www.openssl.org/source/openssl-${OSSL_VERSION}.tar.gz
tar -xf openssl-${OSSL_VERSION}.tar.gz

cd /nginx/nginx-${NGINX_VERSION}
wget -O brotli.tar.gz https://github.com/google/ngx_brotli/archive/master.tar.gz
tar -xf brotli.tar.gz

wget -O vts.tar.gz https://github.com/vozlt/nginx-module-vts/archive/v${VTS_VERSION}.tar.gz
tar -xf vts.tar.gz

sed -i "0,/CFLAGS\=\\\"\\\"/{/CFLAGS\=\\\"\\\"/ s/$/ --add-module=\/nginx\/nginx-${NGINX_VERSION}\/debian\/modules\/incubator-pagespeed-ngx-${NPS_VERSION} ${PS_NGX_EXTRA_FLAGS} --add-module=\/nginx\/nginx-${NGINX_VERSION}\/ngx_brotli-master --add-module=\/nginx\/nginx-${NGINX_VERSION}\/nginx-module-vts-${VTS_VERSION} --with-openssl=\/nginx\/nginx-${NGINX_VERSION}\/openssl-${OSSL_VERSION}/}" /nginx/nginx-${NGINX_VERSION}/debian/rules
sed -i "s/CFLAGS\=\\\"\\\"/CFLAGS\=\\\"-Wno-missing-field-initializers\\\"/" /nginx/nginx-${NGINX_VERSION}/debian/rules

dpkg-buildpackage -b
