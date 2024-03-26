#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
source global_variables.sh
THIS_DIR=$(cd $(dirname $0) && pwd)
SRCBRANCH='lf-5.15.71_2.2.0'
TIM_VX_SRC='https://github.com/nxp-imx/tim-vx-imx.git'
PKG_CONFIG_SYSROOT_DIR="/"

EXTRA_OECMAKE=" \
  -DCONFIG=YOCTO \
  -DTIM_VX_ENABLE_TEST=off \
  -DTIM_VX_USE_EXTERNAL_OVXLIB=on \
  -DCMAKE_INSTALL_PREFIX=${D}/usr/ \
  -DCMAKE_INSTALL_LIBDIR=lib/ \
  -DOVXLIB_INC=/usr/include/${GCC_ARCH}/OVXLIB/ \
  -DOVXLIB_LIB=/usr/lib/${GCC_ARCH}/libovxlib.so
"

pushd ${WORKDIR} && \
  git clone -b ${SRCBRANCH} ${TIM_VX_SRC} ${S} && \
  popd

pushd ${S} && \
  git clean -df && \
  git apply ${D}/tim-vx-remove-Werror.patch
  mkdir build && pushd build && \
  cmake ${EXTRA_OECMAKE} .. && make -j`nproc` all install && \
  popd && popd

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
