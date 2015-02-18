
# Introduction

Dockerfile for installation of [matrix] open federated Instant Messaging and
VoIP communication server.

[matrix]: matrix.org

# Configuration

To configure run the image with "generate" as argument. You have to setup the
server name and domain and the rootpath. After this you have to edit the
generated homeserver.yaml file.

Example:

    docker run -v /tmp/data:/data --rm -e ROOTPATH=/data -e SERVER_NAME=localhost matrix:test generate

# Start

For starting you need the ROOTPATH environment variable and the port binding.

    docker run -d -p 8448:8448 -v /tmp/data:/data -e ROOTPATH=/data matrix:test start

# environment variables

ROOTPATH
  ~ root of all datafiles

SERVER_NAME
  ~ Server and domain name; needed only at generating time


