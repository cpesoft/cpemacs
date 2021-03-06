# start with build container
FROM ubuntu:hirsute AS builder

ENV http_proxy "$HTTP_PROXY"
ENV https_proxy "$HTTPS_PROXY"

# update and install base packages
RUN \
  apt-get update \
  && apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  wget \
  golang

# install gotty via go get
RUN \
  mkdir -p /tmp/gotty && \
  GOPATH=/tmp/gotty go get github.com/sorenisanerd/gotty

# main container
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
  tzdata \
  procps \
  sudo \
  emacs-nox \
  ripgrep fd-find
  
# Ensure UTF-8 and correct locale
RUN \
  locale-gen de_DE.UTF-8 && \
  update-locale LANG=de_DE.UTF-8
ENV LANG       de_DE.UTF-8
ENV LANGUAGE   de_DE.UTF-8
ENV LC_ALL     de_DE.UTF-8

# Set timezone in env
ENV TZ Europe/Berlin

# copy gotty from builder
COPY --from=builder /tmp/gotty/bin/gotty /usr/local/bin/gotty

# create and switch to user
RUN \
  useradd --create-home --groups sudo --shell /bin/bash cpe --uid 1000 

# passwordless sudo (only temporary?)  
RUN \
 echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER cpe
WORKDIR /home/cpe

# set config
COPY gotty.cfg .gotty

# set terminal emulation
ENV TERM xterm-256colors

# disable WebGL due to bug in xterm.js
# see: https://github.com/sorenisanerd/gotty/issues/15
# see: https://github.com/xtermjs/xterm.js/issues/3357#issuecomment-852907822
ENV GOTTY_ENABLE_WEBGL 0

# install doom emacs
RUN \
  git clone --depth 1 https://github.com/hlissner/doom-emacs .emacs.d \
  && mkdir -p ~/.doom.d \
  && cp ~/.emacs.d/init.example.el ~/.doom.d/init.el \
  && cp ~/.emacs.d/core/templates/config.example.el ~/.doom.d/config.el \
  && cp ~/.emacs.d/core/templates/packages.example.el ~/.doom.d/packages.el \
  && ~/.emacs.d/bin/doom sync

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
