FROM alpine:3.10.3
RUN apk update && \
      apk add --no-cache \
      openssl==1.1.1d-r0 && \
      rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
