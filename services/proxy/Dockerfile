FROM nginx
EXPOSE 80
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template
CMD set -ex; \
    envsubst '$SITE' \
      < /etc/nginx/conf.d/default.conf.template \
      > /etc/nginx/conf.d/default.conf; \
    exec nginx -g 'daemon off;'
