#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
THIS_DIR=$(cd $(dirname $0) && pwd)
SRCBRANCH='3.9.x'
SRCREV="52b2447247f535663ac1c292e088b4b27d2910ef"
SRC_URI="https://github.com/protocolbuffers/protobuf.git"
EXTRA_OECONF="--with-protoc=echo \
          --includedir=${D}${includedir}/tensorflow-protobuf \
          --prefix=${D}/usr/"

pushd ${WORKDIR} && \
  git clone -b ${SRCBRANCH} ${SRC_URI} ${S} && \
  popd

pushd ${S} && \
  git reset ${SRCREV} --hard && \
  git clean -df && \
  git submodule update --init --recursive && \
  git am $THIS_DIR/${PN}-patch/*.patch && \
  ./autogen.sh && \
  ./configure ${EXTRA_OECONF} && \
  make -j`nproc` && \
  make install && \
  ldconfig && \
  popd

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
