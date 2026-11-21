# docker-nginx

Базовый образ `ghcr.io/sitkoru/nginx` включает NGINX, PageSpeed, Brotli и VTS.
Штатная конфигурация загружает модули автоматически.

Если приложение подменяет целиком `/etc/nginx/nginx.conf`, добавьте в начало
своего файла `include /etc/nginx/modules-enabled/*.conf;`. Затем проверьте
конфигурацию командой `nginx -t` в контейнере.
