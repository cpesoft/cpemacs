FROM alpine:3.12

LABEL version="0.1"
LABEL maintainer="Carsten Perthel <carsten@cpesoft.de>"

# set proxy (via ARGS from docker-compose file)
ENV http_proxy "$HTTP_PROXY"
ENV https_proxy "$HTTPS_PROXY"

# install base packages
RUN \
  apk update \
  && apk upgrade \
  && apk add wget go git build-base

# install gotty via go get
RUN \
  mkdir -p /tmp/gotty && \
  GOPATH=/tmp/gotty go get github.com/yudai/gotty && \
  mv /tmp/gotty/bin/gotty /usr/local/bin/ && \
  rm -rf /tmp/gotty

# ###############################################################################
# # RESET PROXY SETTINGS
# ###############################################################################

ENV http_proxy ""
ENV https_proxy ""

# ###############################################################################
# # CONFIGURE CONTAINER ENTRYPOINT
# ###############################################################################

CMD ["gotty", "--permit-write", "--reconnect", "/bin/sh"]

# ###############################################################################
# # EXPOSE PORTS AND VOLUMES
# ###############################################################################

EXPOSE 8080

# ###############################################################################
# # END OF DOCKERFILE
# ###############################################################################

