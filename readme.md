
# Introduction

Dockerfile for installation of [matrix] open federated Instant Messaging and
VoIP communication server.

[matrix]: matrix.org

# Configuration

To configure run the image with "generate" as argument. You have to setup the
server name and domain and the rootpath. After this you have to edit the
generated homeserver.yaml file.

Example:

    $ docker run -v /tmp/data:/data --rm -e ROOTPATH=/data -e SERVER_NAME=localhost silviof/docker-matrix generate

# Start

For starting you need the ROOTPATH environment variable and the port bindings.

    $ docker run -d -p 8448:8448 -p 3478:3478 -v /tmp/data:/data -e ROOTPATH=/data silviof/docker-matrix start

# version information

To get the installed synapse version you can run the image with `version` as
argument or look at the container via cat.

    $ docker run -ti --rm silviof/docker-matrix version
    -=> Matrix Version: v0.7.1-0-g894a89d
    # docker exec -it CONTAINERID cat /synapse.version
    v0.7.1-0-g894a89d

# environment variables

ROOTPATH
  ~ root of all datafiles

SERVER_NAME
  ~ Server and domain name; needed only at generating time


