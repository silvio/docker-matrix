
# Introduction

Dockerfile for installation of [matrix] open federated Instant Messaging and
VoIP communication server.

[matrix]: matrix.org

# Configuration

To configure run the image with "generate" as argument. You have to setup the
server domain and a `/data`-directory. After this you have to edit the
generated homeserver.yaml file. Don't forget to configure the `vector.im.conf`
file if you need the vector.im web client. Rename this file to deactivate
vector.im

To get the things done, "generate" will create a own self-signed certificate.

> This needs to be changed for production usage.

Example:

    $ docker run -v /tmp/data:/data --rm -e SERVER_NAME=localhost silviof/docker-matrix generate

# Start

For starting you need the port bindings and a mapping for the
`/data`-directory.

    $ docker run -d -p 8448:8448 -p 3478:3478 -v /tmp/data:/data silviof/docker-matrix start

# Port configurations

This following ports are used in the container. You can use `-p`-option on
`docker run` to configure this part (eg.: `-p 443:8448`).

* turnserver: 3478,3479,5349,5350 udp and tcp
* homeserver: 8008,8448 tcp
* [vector.im] web client: defaults to 8080

[vector.im]: https://vector.im

# Version information

To get the installed synapse version you can run the image with `version` as
argument or look at the container via cat.

    $ docker run -ti --rm silviof/docker-matrix version
    -=> Matrix Version: v0.7.1-0-g894a89d
    # docker exec -it CONTAINERID cat /synapse.version
    v0.7.1-0-g894a89d

# Environment variables

* `SERVER_NAME`: Server and domain name, mandatory, needed only  for `generate`
* `REPORT_STATS`: statistic report, mandatory, values: `yes` or `no`, needed
  only for `generate`

# build specific arguments

* `BV_SYN`: synapse version, optional, defaults to `master`
* `BV_VEC`: vector version, optional, defaults to `master`
* `BV_TUR`: coturn turnserver version, optional, defaults to `master`

For building of synapse version v0.11.0-rc2 and vector with commit a9fc47e add
`--build-arg BV_SYN=v0.11.0-rc2 --build-arg BV_VEC=a9fc47efd77` to the `docker
build` command.

# Exported volumes

* `/data`: data-container

