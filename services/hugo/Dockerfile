FROM alpine

RUN apk update
RUN apk add curl

ENV HUGO_VERSION 0.40.1

RUN set -ex; \
    mkdir -p /opt/hugo; \
    curl -fsSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
      | tar xzv -C /opt/hugo

ENV PATH /opt/hugo:${PATH}
ENTRYPOINT ["hugo"]
