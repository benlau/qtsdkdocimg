#!/bin/bash

set -e

QTVER=5.9.9
DOCKERIMAGENAME=benlau/qtsdk:${QTVER}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

docker run --rm -v "$PWD:/src" --user $(id -u):$(id -g) -it ${DOCKERIMAGENAME} /bin/bash
