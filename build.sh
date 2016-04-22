#!/bin/bash -ex

DOCKER_IMAGE=${DOCKER_IMAGE:-"machinekit/mk-builder:base"}
MIRROR=${MIRROR:-"http://http.debian.net/debian/"}
CUSTOM_APP=${CUSTOM_APP:-"custom_apps.sh"}
CUSTOM_IMG=${CUSTOM_IMG:-"custom_image.sh"}
DEFUSR=${DEFUSR:-"mk"}
DEFPWD=${DEFPWD:-"machinekit"}
VERSION=machinekit-1.0
HOSTNAME=machinekit
ARCH=armhf
CONF=jessie.conf
SUITE=jessie
PROOT_OPTS="-b /dev/null -b /dev/zero -b /dev/pts -b /dev/shm -b /dev/urandom"
TOPDIR="$(dirname "$(readlink -f $0)")"

# add additional boards here, space separated lists
BOARDS="Cubieboard2"

for board in ${BOARDS}; do
    echo Building image for ${board}
    docker run --rm=true --privileged -e MIRROR=${MIRROR} \
        -e HOSTNAME=${HOSTNAME} \
        -e BOARD=${board} \
        -e VERSION=${VERSION} \
        -e CUSTOM_APP=${board}/${CUSTOM_APP} \
        -e CUSTOM_IMG=${board}/${CUSTOM_IMG} \
        -e DEFUSR=${DEFUSR} -e DEFPWD=${DEFPWD} \
        -e ARCH=${ARCH} -e CONF=${CONF} -e SUITE=${SUITE} \
        -e PROOT_OPTS="${PROOT_OPTS}" \
        -v $(pwd):/work \
        ${DOCKER_IMAGE} /work/helper.sh

    # create bmap
    ${TOPDIR}/bmap-tools/bmaptool \
        create ${TOPDIR}/images/${board}-${VERSION}.img \
        -o ${TOPDIR}/images/${board}-${VERSION}.bmap

    bzip2 -9 -f ${TOPDIR}/images/${board}-${VERSION}.img
done
