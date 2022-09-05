#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
THIS_DIR=$(cd $(dirname $0) && pwd)
SRC_URI="git://source.codeaurora.org/external/imx/tflite-vx-delegate-imx.git"
SRCBRANCH="lf-5.15.32_2.0.0"
SRCREV="b2db210794da007a31d75835af20b79a50d16c30"

SRC_URI_TF="git://source.codeaurora.org/external/imx/tensorflow-imx.git"
SRCBRANCH_TF="lf-5.15.32_2.0.0"
SRCREV_TF="9f93a90ef0577204787bd8bb1ca75cd46902ab64"

PKG_CONFIG_SYSROOT_DIR="/"
STAGING_DIR_HOST=${D}

EXTRA_OECMAKE="-DCMAKE_SYSROOT=${PKG_CONFIG_SYSROOT_DIR}"
EXTRA_OECMAKE+=" \
  -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
  -DTIM_VX_INSTALL=${STAGING_DIR_HOST}/usr \
  -DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=${WORKDIR}/tfgit \
  -DVX_DELEGATE_USE_TFLITE_LIB_FROM_SDK=on \
  ${S} \
"

## Get Source Code ##
pushd ${WORKDIR} && \
  git clone -b ${SRCBRANCH} ${SRC_URI} ${S} && \
  popd

pushd ${S} && \
  git reset ${SRCREV} --hard && \
  git clean -df && \
  git submodule update --init --recursive && \
  git am $THIS_DIR/tensorflow-lite-patch/*.patch && \
  popd

## Get Tensorflow Code ##
pushd ${WORKDIR} && \
  git clone -b ${SRCBRANCH_TF} ${SRC_URI_TF} ${WORKDIR}/tfgit && \
  popd

pushd ${WORKDIR}/tfgit && \
  git reset ${SRCREV_TF} --hard && \
  git clean -df && \
  git submodule update --init --recursive && \
  popd

### Build ###
mkdir -p ${B} && \
pushd ${B} && \
  cmake ${EXTRA_OECMAKE} .. && \
  make -j`nproc` && \
popd

### do_install() ###
# install libraries
install -d ${D}${libdir}
for lib in ${B}/lib*.so*
do
    cp --no-preserve=ownership -d $lib ${D}${libdir}
done

# install header files
install -d ${D}${includedir}/tensorflow-lite-vx-delegate
cd ${S}
cp --parents \
    $(find . -name "*.h*") \
    ${D}${includedir}/tensorflow-lite-vx-delegate

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
