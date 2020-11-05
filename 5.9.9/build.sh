#!/bin/bash

set -e

QTVER=5.9.9
QTSRCFOLDER=qt-everywhere-opensource-src-5.9.9
QTSRCURL=https://download.qt.io/archive/qt/5.9/5.9.9/single/qt-everywhere-opensource-src-5.9.9.tar.xz
QTSRCFILE=$(basename ${QTSRCURL})
SCRIPTDIR=$(realpath $(dirname "$0"))
BUILDDIR=${PWD}/build-${QTVER}
DOWNLOADDIR=${PWD}
DESTDIR=${BUILDDIR}/opt
QTSRCDIR=${DOWNLOADDIR}/${QTSRCFOLDER}
DOCKERIMAGENAME=benlau/qtsdk:${QTVER}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

wget -nc ${QTSRCURL}
md5sum --check $SCRIPTDIR/md5sums.txt

if [ ! -d ${QTSRCDIR} ]
then
  tar xvf ${QTSRCFILE}
fi

mkdir -p ${BUILDDIR}
pushd ${BUILDDIR}
cat > tmp-build.sh <<EOF
#!/bin/bash
set -e
cd /src
./configure \
    -confirm-license \
    -prefix "/opt/Qt/$QTVER" \
    -bindir "/opt/Qt/$QTVER/usr/lib/qt5/bin" \
    -libdir "/opt/Qt/$QTVER/usr/lib/" \
    -docdir "/opt/Qt/$QTVER/usr/share/qt5/doc" \
    -headerdir "/opt/Qt/$QTVER/usr/include/qt5" \
    -datadir "/opt/Qt/$QTVER/usr/share/qt5" \
    -archdatadir "/opt/Qt/$QTVER/usr/lib/x86_64-linux-gnu/qt5" \
    -plugindir "/opt/Qt/$QTVER//usr/lib/x86_64-linux-gnu/qt5/plugins" \
    -importdir "/opt/Qt/$QTVER//usr/lib/x86_64-linux-gnu/qt5/imports" \
    -translationdir "/opt/Qt/$QTVER/usr/share/qt5/translations" \
    -hostdatadir "/opt/Qt/$QTVER/usr/lib/x86_64-linux-gnu/qt5" \
    -sysconfdir "/etc/xdg" \
    -examplesdir "/opt/Qt/$QTVER/usr/lib/x86_64-linux-gnu/qt5/examples" \
    -opensource \
    -plugin-sql-sqlite \
    -no-sql-sqlite2 \
    -system-harfbuzz \
    -system-zlib \
    -system-libpng \
    -system-libjpeg \
    -no-rpath \
    -verbose \
    -no-strip \
    -no-separate-debug-info \
    -qpa xcb \
    -xcb \
    -glib \
    -icu \
    -accessibility \
    -no-directfb \
    -no-use-gold-linker \
    -opengl desktop \
    -nomake examples -nomake tests
time make
time make install
EOF
chmod u+x tmp-build.sh

cat > Dockerfile <<EOF
FROM ubuntu:18.04

MAINTAINER Ben Lau version: 0.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential mesa-common-dev libjpeg-dev libpng-dev libicu-dev \
    libgl1-mesa-dev \
    git \
    python2.7 \
    golang ca-certificates \
    && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV GOPATH /usr/lib/golang
RUN go get qpm.io/qpm
RUN ln -s /usr/lib/golang/bin/qpm /usr/bin/qpm
ADD opt /opt
RUN ln -s /opt/Qt/${QTVER}/usr/lib/qt5/bin/qmake /usr/bin/qmake
RUN ln -s /usr/bin/python2.7 /usr/bin/python
ENV LD_LIBRARY_PATH /opt/Qt/${QTVER}/usr/lib
EOF

cat > test.sh <<EOF
#!/bin/bash
set -e
cd /tmp
git clone https://github.com/benlau/qtshell.git
cd qtshell/tests/qtshellunittests
qpm install
qmake
make
QT_QPA_PLATFORM=minimal ./unittests
EOF
chmod u+x test.sh

if [ ! -d ${DESTDIR}/Qt ]
then
  echo "Building QT"
  mkdir -p ${DESTDIR}
  docker run --rm  -v "${QTSRCDIR}:/src" \
                   -v "${BUILDDIR}:/conf" \
                   -v "${BUILDDIR}/opt:/opt" \
                    --user $(id -u):$(id -g) -t benlau/qtsdk-builder /conf/tmp-build.sh
else
  echo ${DESTDIR}/Qt existed. Skip building QT
fi

echo Building Docker image
docker build -t ${DOCKERIMAGENAME} .

echo Running test

docker run --rm -v "$PWD:/conf" --user $(id -u):$(id -g) -it ${DOCKERIMAGENAME} /conf/test.sh

echo Done
echo You may run the docker image by following command:
echo docker run --rm -v "\$PWD:/conf" --user $(id -u):$(id -g) -it ${DOCKERIMAGENAME} /bin/bash
popd
