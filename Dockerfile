FROM debian:jessie

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# update and upgrade
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
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
	subversion \
    && apt-get clean

# install/upgrade pip
RUN pip install --upgrade pip setuptools

# installing vector.im with nodejs/npm
RUN curl -sL https://deb.nodesource.com/setup | bash - ;\
    apt-get install -y nodejs ;\
    npm install -g webpack http-server ;\
    git clone https://github.com/vector-im/vector-web.git ;\
    cd vector-web ;\
    npm install ;\
    npm run build

# install homerserver template
ADD adds/start.sh /start.sh
RUN chmod a+x /start.sh

# startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448
VOLUME ["/data"]

# install synapse homeserver
RUN git clone https://github.com/matrix-org/synapse /tmp-synapse

# the "git clone" is cached, we need to invalidate the docker cache here
ADD http://www.random.org/strings/?num=1&len=10&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new uuid
RUN cd /tmp-synapse \
    && git pull \
    && git describe --always --long | tee /synapse.version
RUN pip install --process-dependency-links /tmp-synapse

# install turn-server
RUN svn co http://coturn.googlecode.com/svn/trunk coturn \
    && cd coturn \
    && ./configure \
    && make \
    && make install

