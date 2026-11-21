FROM nginx:1.30.7@sha256:7fad6c0dff97965adbddf28027d934b111fc0221a554315dc274712f3fba24d3 AS nginx-base

FROM nginx-base AS modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libbrotli-dev libpcre2-dev libssl-dev zlib1g-dev
COPY build.sh /build.sh
RUN sh /build.sh

FROM nginx-base
COPY --from=modules /usr/src/nginx/objs/*.so /usr/lib/nginx/modules/

RUN set -eu; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y --no-install-recommends gpg; \
    curl -fsSL https://packages.modpagespeed.com/pubkey.gpg -o /tmp/modpagespeed.gpg; \
    fingerprint="$(gpg --batch --show-keys --with-colons /tmp/modpagespeed.gpg \
        | awk -F: '$1 == "pub" { primary = 1; next } primary && $1 == "fpr" { print $10; primary = 0 }')"; \
    test "$fingerprint" = DF00E296BE9141CEA5411346F50D6054F10712A0; \
    gpg --batch --dearmor -o /usr/share/keyrings/modpagespeed.gpg /tmp/modpagespeed.gpg; \
    echo 'deb [signed-by=/usr/share/keyrings/modpagespeed.gpg] https://packages.modpagespeed.com/apt trixie main' \
        > /etc/apt/sources.list.d/modpagespeed.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        "nginx-module-pagespeed-nginxorg=2.9.2-r1+ngx${NGINX_VERSION}~trixie"; \
    printf 'load_module modules/%s.so;\n' \
        ngx_http_brotli_filter_module ngx_http_brotli_static_module ngx_http_vhost_traffic_status_module \
        > /etc/nginx/modules-enabled/60-sitkoru.conf; \
    sed -i '1i include /etc/nginx/modules-enabled/*.conf;' /etc/nginx/nginx.conf; \
    nginx -t; \
    rm -rf /var/lib/apt/lists/* /tmp/modpagespeed.gpg /root/.gnupg
