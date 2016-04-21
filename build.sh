#!/bin/bash -ex
DOCKER_IMAGE=${DOCKER_IMAGE:-"machinekit/mk-builder:base"}
MIRROR=${MIRROR:-"http://http.debian.net/debian/"}
CUSTOM_APP=${CUSTOM_APP:-"custom_apps.sh"}
CUSTOM_IMG=${CUSTOM_IMG:-"custom_image.sh"}
DEFUSR=${DEFUSR:-"mk"}
DEFPWD=${DEFPWD:-"machinekit"}
HOSTNAME=machinekit
ARCH=armhf
CONF=jessie.conf
SUITE=jessie
PROOT_OPTS="-b /dev/null -b /dev/zero -b /dev/pts -b /dev/shm -b /dev/urandom"

docker run --rm=true --privileged -e MIRROR=${MIRROR} -e HOSTNAME=${HOSTNAME} \
    -e CUSTOM_APP=${CUSTOM_APP} -e CUSTOM_IMG=${CUSTOM_IMG} \
    -e DEFUSR=${DEFUSR} -e DEFPWD=${DEFPWD} \
    -e ARCH=${ARCH} -e CONF=${CONF} -e SUITE=${SUITE} \
    -e PROOT_OPTS="${PROOT_OPTS}" \
    -v $(pwd):/work \
    ${DOCKER_IMAGE} /work/helper.sh
