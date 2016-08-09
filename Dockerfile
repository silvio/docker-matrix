FROM alpine:3.4

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# install homerserver template
COPY adds/start.sh /start.sh

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

# use --build-arg REBUILD=$(date) to invalidate the cache and upgrade all
# packages
ARG REBUILD=1
RUN chmod a+x /start.sh \
    && apk update \
    && apk add \
        bash \
        coreutils \
        curl \
        file \
        gcc \
        git \
        libevent \
        libevent-dev \
        libffi \
        libffi-dev \
        libjpeg-turbo \
        libjpeg-turbo-dev \
        libssl1.0 \
        libtool \
        libxml2 \
        libxml2-dev \
        libxslt \
        libxslt-dev \
        linux-headers \
        make \
        musl \
        musl-dev \
        openldap \
        openldap-dev \
        openssl-dev \
        pwgen \
        py-pip \
        py-virtualenv \
        python \
        python-dev \
        sqlite \
        sqlite-libs \
        unzip \
        zlib \
        zlib-dev \
        ; \
    pip install python-ldap \
    && pip install lxml \
    ; \
    curl -L https://github.com/matrix-org/synapse/archive/$BV_SYN.zip -o s.zip \
    && unzip s.zip \
    && cd /synapse-$(echo $BV_SYN | tr -d v) \
    && pip install --process-dependency-links . \
    && GIT_SYN=$(git ls-remote https://github.com/matrix-org/synapse $BV_SYN | cut -f 1) \
    && echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version \
    && cd / \
    && rm -rf synapse-$(echo $BV_SYN | tr -d v) \
    && rm s.zip \
    ; \
    curl -L https://github.com/coturn/coturn/archive/$BV_TUR.zip -o c.zip \
    && unzip c.zip \
    && cd /coturn-$(echo $BV_TUR | tr -d v) \
    && ./configure \
    && make \
    && make install \
    && GIT_TUR=$(git ls-remote https://github.com/coturn/coturn $BV_TUR | cut -f 1) \
    && echo "coturn:  $BV_TUR ($GIT_TUR)" >> /synapse.version \
    && cd / \
    && rm -rf coturn-$(echo $BV_TUR | tr -d v) \
    && rm c.zip \
    ; \
    apk del \
        coreutils \
        file \
        gcc \
        git \
        libevent-dev \
        libffi-dev \
        libjpeg-turbo-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        make \
        musl-dev \
        openldap-dev \
        openssl-dev \
        python-dev \
        sqlite-libs \
        zlib-dev \
        ; \
    rm -rf /var/lib/apk/* /var/cache/apk/*
