QtSDK Docker Image Builder
=========================

This repo contains a set of script to build QtSdk with a specific version as a docker image for CI purpose.

Usage
=====

1) Pulling the docker image

```
docker pull benlau/qtsdk:5.15.1

#Replace the "5.15.1" with other supported version
```

The list of supported Qt version: [benlau/qtsdk Tags - Docker Hub](https://hub.docker.com/r/benlau/qtsdk/tags)

2) Build and run Qt Application within the docker image

```
docker run --rm -v "$PWD:/src" --user $(id -u):$(id -g) -i -t benlau/qtsdk:5.15.1 /bin/bash
cd /src
qmake
make
#run your unit tests
```

Example: LINK to QuickFlux
[quickflux/.travis.yml at master · benlau/quickflux](https://github.com/benlau/quickflux/blob/master/.travis.yml)


3) Copy the SDK from docker image to your host computer

```
docker run --rm benlau/qtsdk:5.15.1 tar Ccf /opt - Qt | tar Cxf /opt -
```

Building the Docker Image
============

In case you need the QtSdk to support a special feature, you may compile it by yourself.

1) Build benlau/qtsdk-builder

```
./builder/build-docker-image.sh
```

This command builds the benlau/qtsdk-builder Docker image for building Qt SDK.

2) Run $QTVER/build.sh

Example:

```
mkdir -p build
cd build
../5.15.1/build.sh
```

The command will fetch QtSDK from the Qt website and build the SDK and docker image.

You may edit the script to add/remove options passed to the Qt SDK
