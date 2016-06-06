FROM alpine:3.4

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# update and upgrade
RUN apk update \
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
	linux-headers \
	make \
	musl \
	musl-dev \
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
	;

# install homerserver template
ADD adds/start.sh /start.sh
RUN chmod a+x /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448
VOLUME ["/data"]

# install/upgrade pip
#RUN pip install --upgrade pip setuptools

# "git clone" is cached, we need to invalidate the docker cache here
# to use this add a --build-arg INVALIDATEBUILD=$(data) to your docker build
# parameter.
ENV INVALIDATEBUILD=notinvalidated

# install synapse homeserver
ENV BV_SYN=master
# https://github.com/python-pillow/Pillow/issues/1763
ENV LIBRARY_PATH=/lib:/usr/lib
ADD https://github.com/matrix-org/synapse/archive/$BV_SYN.zip s.zip
RUN unzip s.zip \
    && rm s.zip \
    && cd /synapse-$BV_SYN \
    && pip install --process-dependency-links . \
    && GIT_SYN=$(git ls-remote https://github.com/matrix-org/synapse $BV_SYN | cut -f 1) \
    && echo "synapse: $BV_SYN ($GIT_SYN)" >> /synapse.version \
    && rm -rf /synapse-$BV_SYN

# install turn-server
ENV BV_TUR=master
ADD https://github.com/coturn/coturn/archive/$BV_TUR.zip c.zip
RUN unzip c.zip \
    && rm c.zip \
    && cd /coturn-$BV_TUR \
    && ./configure \
    && make \
    && make install \
    && GIT_TUR=$(git ls-remote https://github.com/coturn/coturn $BV_TUR | cut -f 1) \
    && echo "coturn:  $BV_TUR ($GIT_TUR)" >> /synapse.version \
    && rm -rf /coturn-$BV_TUR

# remove development dependencies
RUN apk del \
	coreutils \
	file \
	gcc \
	git \
	libevent-dev \
	libffi-dev \
	libjpeg-turbo-dev \
	libtool \
	linux-headers \
	make \
	musl-dev \
	openssl-dev \
	python-dev \
	sqlite-libs \
	zlib-dev \
    && rm -rf /var/lib/apk/* /var/cache/apk/*

