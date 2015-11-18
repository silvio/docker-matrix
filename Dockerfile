FROM debian:jessie

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# update and upgrade
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
	build-essential \
	curl \
	git-core \
	libevent-dev \
	libffi-dev \
	libjpeg-dev \
	libsqlite3-dev \
	libssl-dev \
	pwgen \
	python-pip \
	python-virtualenv \
	python2.7-dev \
	sqlite3 \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# install homerserver template
ADD adds/start.sh /start.sh
RUN chmod a+x /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448
VOLUME ["/data"]

# install/upgrade pip
RUN pip install --upgrade pip setuptools

# "git clone" is cached, we need to invalidate the docker cache here
# to use this add a --build-arg INVALIDATEBUILD=$(data) to your docker build
# parameter.
ARG INVALIDATEBUILD=notinvalidated

# installing vector.im with nodejs/npm
ARG BV_VEC=master
RUN curl -sL https://deb.nodesource.com/setup | bash - \
    && apt-get install -y nodejs \
    && npm install -g webpack http-server \
    && git clone https://github.com/vector-im/vector-web.git \
    && cd vector-web \
    && git reset --hard $BV_VEC \
    && npm install \
    && npm run build

# install synapse homeserver
ARG BV_SYN=master
RUN git clone https://github.com/matrix-org/synapse /tmp-synapse \
    && cd /tmp-synapse \
    && git reset --hard $BV_SYN \
    && git describe --always --long | tee /synapse.version
RUN pip install --process-dependency-links /tmp-synapse

# install turn-server
ARG BV_TUR=master
RUN git clone https://github.com/coturn/coturn.git /tmp-coturn \
    && cd /tmp-coturn \
    && git reset --hard $BV_TUR \
    && ./configure \
    && make \
    && make install

