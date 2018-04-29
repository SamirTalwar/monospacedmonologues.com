FROM scratch

COPY --from=samirtalwar/hugo /opt/hugo/hugo /usr/local/bin/hugo

WORKDIR /var/www
COPY . ./

ENTRYPOINT ["hugo"]
