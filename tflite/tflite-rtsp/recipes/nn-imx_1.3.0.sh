#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
THIS_DIR=$(cd $(dirname $0) && pwd)
SRCBRANCH='imx_1.3.0'
STAGING_BINDIR_NATIVE='/usr/bin'
NN_IMX_SRC='git://source.codeaurora.org/external/imx/nn-imx.git'
SRCREV="87e262fc89a7f4819b35188f9b2e7117b8563b89"
STAGING_DIR_HOST="/"

pushd ${WORKDIR} && git clone -b ${SRCBRANCH} ${NN_IMX_SRC} ${S} && popd
pushd ${S} && \
  git reset ${SRCREV} --hard && \
  git clean -df && \
  AQROOT=`pwd` SDKTARGETSYSROOT=${STAGING_DIR_HOST} make -j`nproc` && \
  popd

## do_install () ##
install -d ${D}${libdir}
install -d ${D}${includedir}/OVXLIB
install -d ${D}${includedir}/nnrt
cp -d ${S}/*.so* ${D}${libdir}
cp -r ${S}/include/OVXLIB/* ${D}/${includedir}/OVXLIB
cp -r ${S}/include/nnrt/* ${D}/${includedir}/nnrt

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
