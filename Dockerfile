FROM nginx:alpine

EXPOSE 80

RUN apk update
RUN apk add curl

ENV HUGO_VERSION 0.40.1

RUN set -ex; \
    curl -fsSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
      | tar xz -C /usr/local/bin hugo

COPY /server/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /src
COPY . ./

ENTRYPOINT ["./server/run"]
