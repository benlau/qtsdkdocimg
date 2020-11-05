FROM ubuntu:18.04

MAINTAINER Ben Lau version: 0.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential mesa-common-dev libjpeg-dev libpng-dev libicu-dev \
    libgl1-mesa-dev \
    python2.7 \
    libxcb-icccm4-dev libxcb-shm0-dev libgdm-dev libmtdev-dev \
    libxcb-image0-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb-keysyms1-dev \
    libxcb-render0-dev libxcb-render-util0-dev libxcb-xinerama0-dev \
    && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

##RUN update-alternatives --install /usr/bin/python2.7 python /usr/bin/python2 20
RUN ln -s /usr/bin/python2.7 /usr/bin/python
