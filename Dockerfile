FROM debian:jessie

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# install homerserver template
COPY adds/start.sh /start.sh

# add supervisor configs
COPY adds/supervisord-matrix.conf /conf/
COPY adds/supervisord-turnserver.conf /conf/
COPY adds/supervisord.conf /

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448
VOLUME ["/data"]

# Git branch to build from
ARG BV_SYN=master
ARG BV_TUR=master
# https://github.com/python-pillow/Pillow/issues/1763
ENV LIBRARY_PATH=/lib:/usr/lib

# user configuration
ENV MATRIX_UID=991 MATRIX_GID=991

# use --build-arg REBUILD=$(date) to invalidate the cache and upgrade all
# packages
ARG REBUILD=1
RUN set -ex \
    && mkdir /uploads \
    && export DEBIAN_FRONTEND=noninteractive \
    && mkdir -p /var/cache/apt/archives \
    && touch /var/cache/apt/archives/lock \
    && apt-get clean \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        bash \
        coreutils \
        coturn \
        file \
        gcc \
        git \
        libevent-2.0-5 \
        libevent-dev \
        libffi-dev \
        libffi6 \
        libgnutls28-dev \
        libjpeg62-turbo \
        libjpeg62-turbo-dev \
        libldap-2.4-2 \
        libldap2-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libssl-dev \
        libssl1.0.0 \
        libtool \
        libxml2 \
        libxml2-dev \
        libxslt1-dev \
        libxslt1.1 \
        linux-headers-amd64 \
        make \
        pwgen \
        python \
        python-dev \
        python-pip \
        python-psycopg2 \
        python-virtualenv \
        sqlite \
        zlib1g \
        zlib1g-dev \
    ; \
    pip install --upgrade pip ;\
    pip install --upgrade python-ldap ;\
    pip install --upgrade lxml ;\
    pip install --upgrade supervisor \
    ; \
    git clone --branch $BV_SYN --depth 1 https://github.com/matrix-org/synapse.git \
    && cd /synapse \
    && pip install --upgrade --process-dependency-links . \
    && GIT_SYN=$(git ls-remote https://github.com/matrix-org/synapse $BV_SYN | cut -f 1) \
    && echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version \
    && cd / \
    && rm -rf /synapse \
    ; \
    apt-get autoremove -y \
        file \
        gcc \
        git \
        libevent-dev \
        libffi-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        libxslt1-dev \
        linux-headers-amd64 \
        make \
        python-dev \
        zlib1g-dev \
    ; \
    apt-get autoremove -y ;\
    rm -rf /var/lib/apt/* /var/cache/apt/*
