#!/bin/bash
set -e

FILENAME=
readarray -d _ -t strarr <<< "${1/".sh"/""}"
PN=${strarr[0]%$'\n'}
PV=${strarr[1]%$'\n'}
BPN=${PN}
WORKDIR='/workdir'
S=${WORKDIR}'/'${PN}
B="${S}/build"
bindir='usr/bin'
D='/out/'
includedir='usr/include'
libdir='usr/lib'
bindir='usr/bin'
TARGET_ARCH='aarch64'
sysconfdir='/etc'
GCC_ARCH="aarch64-linux-gnu"
mkdir -p ${WORKDIR}

f () {
    errorCode=$? # save the exit code as the first thing done in the trap function
    exit $errorCode  # or use some other value or do return instead
}
trap f ERR
