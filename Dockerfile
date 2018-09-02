FROM debian:stretch-slim

# Maintainer
MAINTAINER Andreas Peters <support@aventer.biz>

# install homerserver template
COPY adds/start.sh /start.sh

# add supervisor configs
COPY adds/supervisord-matrix.conf /conf/
COPY adds/supervisord-turnserver.conf /conf/
COPY adds/supervisord.conf /

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["autostart"]
EXPOSE 8448
VOLUME ["/data"]

# Git branch to build from
ARG BV_SYN=master
ARG BV_TUR=master
ARG TAG_SYN=v0.33.3rc2

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
    && apt-get update -y -q --fix-missing\
    && apt-get upgrade -y \
    && buildDeps=' \
        file \
        gcc \
        git \
        libevent-dev \
        libffi-dev \
        libgnutls28-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libsasl2-dev \
        libsqlite3-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        libxslt1-dev \
        linux-headers-amd64 \
        make \
        python-dev \
        python-setuptools \
        zlib1g-dev \
    ' \
    && apt-get install -y --no-install-recommends \
        $buildDeps \
        bash \
        coreutils \
        coturn \
        libevent-2.0-5 \
        libffi6 \
        libjpeg62-turbo \
        libldap-2.4-2 \
        libssl1.1 \
        libtool \
        libxml2 \
        libxslt1.1 \
        pwgen \
        python \
        python-pip \
        python-psycopg2 \
        python-virtualenv \
	python-jinja2 \
        sqlite \
        zlib1g \
    ; \
    pip install --upgrade wheel ;\
    pip install --upgrade python-ldap ;\
    pip install --upgrade pyopenssl ;\
    pip install --upgrade enum34 ;\
    pip install --upgrade ipaddress ;\
    pip install --upgrade lxml ;\
    pip install --upgrade supervisor \
    ; \
    git clone --branch $BV_SYN --depth 1 https://github.com/matrix-org/synapse.git \
    && cd /synapse \
    git checkout tags/$TAG_SYN \
    && pip install --upgrade --process-dependency-links . \
    && GIT_SYN=$(git ls-remote https://github.com/matrix-org/synapse $BV_SYN | cut -f 1) \
    && echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version \
    && cd / \
    && rm -rf /synapse \
    ; \
    apt-get autoremove -y $buildDeps ; \
    apt-get autoremove -y ;\
    rm -rf /var/lib/apt/* /var/cache/apt/*
