#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
THIS_DIR=$(cd $(dirname $0) && pwd)
SRCBRANCH='lf-5.15.32_2.0.0'
SRCREV='f2550359747106f28d936beb99ee677cda0c5912'
TIM_VX_SRC='https://github.com/NXPmicro/tim-vx-imx.git'
PKG_CONFIG_SYSROOT_DIR="/"

EXTRA_OECMAKE=" \
  -DCONFIG=YOCTO \
  -DTIM_VX_ENABLE_TEST=off \
  -DTIM_VX_USE_EXTERNAL_OVXLIB=on \
  -DCMAKE_INSTALL_PREFIX=${D}/usr/ \
  -DCMAKE_INSTALL_LIBDIR=lib/ \
  -DOVXLIB_INC=${D}/usr/include/OVXLIB/ \
  -DOVXLIB_LIB=${D}/usr/lib/libovxlib.so
"

pushd ${WORKDIR} && \
  git clone -b ${SRCBRANCH} ${TIM_VX_SRC} ${S} && \
  popd

pushd ${S} && \
  git reset ${SRCREV} --hard && \
  git clean -df && \
  mkdir build && pushd build && \
  cmake ${EXTRA_OECMAKE} .. && make -j`nproc` all install && \
  popd && popd

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
