# Docker image for Matrix

- [Matrix Chat](https://riot.im/app/#/room/#dockermatrix:matrix.aventer.biz)
- [Docker Hub](https://hub.docker.com/r/avhost/docker-matrix/tags)
- [Donation](https://liberapay.com/docker-matrix/)

## Notice

With v0.99.5 we publish some changes that can breake the backward compatibility.

We change to python3. We could not test everything. Please come into our chat and/or open a issue on github. 

Please make sure to use our tagged docker images and not the latest one. Specifically in a production environment you should never use :latest as that the version can be broken.

## Creating Issues and Pull request

We are working with the repository at "https://github.com/AVENTER-UG/docker-matrix". If you want to open issues or create pull request, please use that repository.

## Security

We verify the docker layers of our image automaticly with clair. Matrix is not a part of the vulnerability scan, which  means clair will only find vulnerabilities that are part of the OS (operating system).

## Introduction

Dockerfile for installation of [matrix] open federated Instant Messaging and
VoIP communication server.

The riot.im web client has now his own docker file at [github].

[matrix]: https://matrix.org
[github]: https://github.com/AVENTER-UG/matrix-riot-docker

## Contribution

If you want contribute to this project feel free to fork this project, do your
work in a branch and create a pull request.

To support this Dockerimage please pledge via [liberapay].

[liberapay]: https://liberapay.com/docker-matrix/

## Configuration

To configure run the image with "generate" as argument. You have to setup the
server domain and a `/data`-directory. After this you have to edit the
generated homeserver.yaml file.

Please read the synapse [readme file] about configuration settings, 
there is also an [example setup](Example.configs.md) available to read.

[readme file]: https://github.com/matrix-org/synapse/blob/master/README.rst

To get the things done, "generate" will create a self-signed certificate, which should be replaced with a valid certificate if used in production, either by giving synapse access to the valid certificate, or by using a reverse proxy.

It is recommended to run the container with a --user <UID>:<GID> flag, to prevent the container from running as root. However, the synapse process will not run as root if the user flag is not supplied.

Example:

    $ docker run -v /tmp/data:/data --rm --user 991:991 -e SERVER_NAME=localhost -e REPORT_STATS=no avhost/docker-matrix:<VERSION> generate

## Start

For starting you need the port bindings and a mapping for the
`/data`-directory.

    $ docker run -d --user 991:991 -p 8448:8448 -p 8008:8008 -p 3478:3478 -v /tmp/data:/data avhost/docker-matrix:<VERSION> start

## Port configurations

### Matrix Homeserver

The following ports are used in the container for the Matrix server. You can use `-p`-option on
`docker run` to configure this part (eg.: `-p 443:8448`):  
`8008,8448 tcp`

### Coturn server

If you only need STUN to work you  need the following ports:  
`3478, 5349 udp/tcp`  
The server has the following as alt-ports: `3479, 5350 udp/tcp`

For TURN (using the server as a relay) you also need to forward this portrange:  
`49152-65535/udp`  

You may also have to set the external ip of the server in turnserver.conf which is located in the `/data` volume:  
`external-ip=XX.XX.XX.XX`

In case you don't want to expose the whole port range on udp you can change the portrange in turnserver.conf:  
`min-port=XXXXX`  
`max-port=XXXXX`  

## Version information

To get the installed synapse version you can run the image with `version` as
argument or look at the container via cat.

    $ docker run -ti --rm avhost/docker-matrix:<VERSION> version
    -=> Matrix Version
    synapse: master (7e0a1683e639c18bd973f825b91c908966179c15)
    coturn:  master (88bd6268d8f4cdfdfaffe4f5029d489564270dd6)

    # docker exec -it CONTAINERID cat /synapse.version
    synapse: master (7e0a1683e639c18bd973f825b91c908966179c15)
    coturn:  master (88bd6268d8f4cdfdfaffe4f5029d489564270dd6)


## Environment variables

* `SERVER_NAME`: Server and domain name, mandatory, needed only  for `generate`
* `REPORT_STATS`: statistic report, mandatory, values: `yes` or `no`, needed
  only for `generate`
* `MATRIX_UID`/`MATRIX_GID`: UserID and GroupID of user within container which
  runs the synapse server, if the --user flag is not supplied. The files mounted under /data are `chown`ed to this
  ownership. Default is `MATRIX_UID=991` and `MATRIX_GID=991`. It can overriden
  via `-e MATRIX_UID=...` and `-e MATRIX_GID=...` at start time.
* `LD_PRELOAD` This is set by default to use jemalloc as memory allocator, as 
  that has been shown to greatly reduce the memory useage of synapse. To use the default malloc
  the environmental variable has to be emptied, by adding `-e LD_PRELOAD` when running the container.

## build specific arguments

* `BV_SYN`: synapse version, optional, defaults to `master`
* `BV_TUR`: coturn turnserver version, optional, defaults to `master`

For building of synapse version v0.11.0-rc2 and coturn with commit a9fc47e add
`--build-arg BV_SYN=v0.11.0-rc2 --build-arg BV_TUR=a9fc47efd77` to the `docker
build` command.

## diff between system and fresh generated config file

To get a hint about new options etc you can do a diff between your configured
homeserver.yaml and a newly created config file. Call your image with `diff` as
argument.


```
$ docker run --rm -ti -v /tmp/data:/data avhost/docker-matrix:<VERSION> diff
[...]
+# ldap_config:
+#   enabled: true
+#   server: "ldap://localhost"
+#   port: 389
+#   tls: false
+#   search_base: "ou=Users,dc=example,dc=com"
+#   search_property: "cn"
+#   email_property: "email"
+#   full_name_property: "givenName"
[...]
```

For generating of this output its `diff` from `busybox` used. The used diff
parameters can be changed through `DIFFPARAMS` environment variable. The
default is `Naur`.


## Exported volumes

* `/data`: data-container

