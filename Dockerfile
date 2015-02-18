# baseimage is ubuntu precise (LTS)
FROM ubuntu:precise

# Maintainer
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

# set debian/ubuntu config environment to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# here we should setup the initsystem problem
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# update and upgrade
RUN apt-get update -y && apt-get upgrade -y

# development base installation
RUN apt-get install -y build-essential python2.7-dev libffi-dev python-pip \
		       python-setuptools sqlite3 libssl-dev python-virtualenv \
		       libjpeg-dev

# clean up
RUN apt-get clean

# install/upgrade pip
RUN pip install --upgrade pip

# install env template
RUN pip install envtpl

# install synapse homeserver
RUN pip install --process-dependency-links https://github.com/matrix-org/synapse/tarball/master

# install homerserver template
ADD adds/start.sh /start.sh
RUN chmod a+x /start.sh

# ssh and startup configuration
ENTRYPOINT ["/start.sh"]
CMD ["start"]
EXPOSE 8448
