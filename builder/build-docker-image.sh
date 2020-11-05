#!/bin/bash

DOCKERDIR=$(realpath $(dirname "$0"))
IMAGE_NAME=benlau/qtsdk-builder

set -v
docker build --build-arg TIMESTAMP=$(date +"%s") -f "$DOCKERDIR/Dockerfile" -t  $IMAGE_NAME .
