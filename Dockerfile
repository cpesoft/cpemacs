FROM ubuntu:hirsute

LABEL version="0.1"
LABEL maintainer="Carsten Perthel <carsten@cpesoft.de>"

# set proxy (via ARGS from docker-compose file)
ENV http_proxy "$HTTP_PROXY"
ENV https_proxy "$HTTPS_PROXY"

# other ENV variables
ENV DEBIAN_FRONTEND noninteractive

# update and install base packages
RUN \
  apt-get update \
  && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  wget \
  git \
  build-essential \
  apt-utils \
  locales \
  locales-all \
  tzdata
  

#  && apk add wget go git build-base


# Ensure UTF-8 and correct locale
RUN \
  locale-gen de_DE.UTF-8 && \
  update-locale LANG=de_DE.UTF-8
ENV LANG       de_DE.UTF-8
ENV LANGUAGE   de_DE.UTF-8
ENV LC_ALL     de_DE.UTF-8

# install gotty
RUN \
  cd /tmp \
  && wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz \
  && tar xvzf gotty_linux_amd64.tar.gz \
  && mv ./gotty /usr/local/bin

#ENV TERM xterm-256colors
ENV TERM screen

# install gotty via go get
# RUN \
#   mkdir -p /tmp/gotty && \
#   GOPATH=/tmp/gotty go get github.com/yudai/gotty && \
#   mv /tmp/gotty/bin/gotty /usr/local/bin/ && \
#   rm -rf /tmp/gotty

# ###############################################################################
# # RESET PROXY SETTINGS
# ###############################################################################

ENV http_proxy ""
ENV https_proxy ""

# ###############################################################################
# # CONFIGURE CONTAINER ENTRYPOINT
# ###############################################################################

CMD ["gotty", "--permit-write", "--reconnect", "/bin/bash"]

# ###############################################################################
# # EXPOSE PORTS AND VOLUMES
# ###############################################################################

EXPOSE 8080

# ###############################################################################
# # END OF DOCKERFILE
# ###############################################################################

