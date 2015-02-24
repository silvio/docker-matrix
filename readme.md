
# Introduction

Dockerfile for installation of [matrix] open federated Instant Messaging and
VoIP communication server.

[matrix]: matrix.org

# Configuration

To configure run the image with "generate" as argument. You have to setup the
server domain and the rootpath. After this you have to edit the generated
homeserver.yaml file.

To get the things done, "generate" will create a own self-signed certificate.

> This needs to be changed for production usage.

Example:

    $ docker run -v /tmp/data:/data --rm -e ROOTPATH=/data -e SERVER_NAME=localhost silviof/docker-matrix generate

# Start

For starting you need the ROOTPATH environment variable and the port bindings.

    $ docker run -d -p 8448:8448 -p 3478:3478 -v /tmp/data:/data -e ROOTPATH=/data silviof/docker-matrix start

# Port configurations

This following ports are used in the container. You can use `-p`-option on
`docker run` to configure this part (eg.: `-p 443:8448`).

turnserver: 3478,3479,5349,5350 udp and tcp
homeserver: 8008,8448 tcp

# Version information

To get the installed synapse version you can run the image with `version` as
argument or look at the container via cat.

    $ docker run -ti --rm silviof/docker-matrix version
    -=> Matrix Version: v0.7.1-0-g894a89d
    # docker exec -it CONTAINERID cat /synapse.version
    v0.7.1-0-g894a89d

# Environment variables

ROOTPATH
  ~ root of all datafiles

SERVER_NAME
  ~ Server and domain name; needed only at generating time


