FROM debian:9.5-slim

# Maintainer
MAINTAINER Andreas Peters <support@aventer.biz>

# install homerserver template
COPY adds/start.sh /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["autostart"]
EXPOSE 8448
VOLUME ["/data"]

# Git branch to build from
ARG BV_SYN=master
ARG BV_TUR=master
ARG TAG_SYN=v0.99.5.1

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
        zlib1g-dev \
        python3-dev \
        python3-setuptools \
        libpq-dev \
    ' \
    && apt-get install -y --no-install-recommends \
        $buildDeps \
        bash \
        coreutils \
        coturn \
        libffi6 \
        libjpeg62-turbo \
        libssl1.1 \
        libtool \
        libxml2 \
        libxslt1.1 \
        pwgen \
        python3 \
        python3-pip \
        python3-jinja2 \
        sqlite \
        zlib1g \
    ; \
    pip3 install --upgrade wheel ;\
    pip3 install --upgrade psycopg2;\
    pip3 install --upgrade python-ldap ;\
    pip3 install --upgrade lxml \
    ; \
    groupadd -r -g $MATRIX_GID matrix \
    && useradd -r -d /data -M -u $MATRIX_UID -g matrix matrix \
    && chown -R $MATRIX_UID:$MATRIX_GID /data \
    && chown -R $MATRIX_UID:$MATRIX_GID /uploads \
    && git clone --branch $BV_SYN --depth 1 https://github.com/matrix-org/synapse.git \
    && cd /synapse \
    && git checkout tags/$TAG_SYN \
    && pip3 install --upgrade .[all] \
    && GIT_SYN=$(git ls-remote https://github.com/matrix-org/synapse $BV_SYN | cut -f 1) \
    && echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version \
    && cd / \
    && rm -rf /synapse 

USER matrix
