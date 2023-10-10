#!/bin/bash
source global_variables.sh
PN='tensorflow-lite'
PV='2.9.1'
S=${WORKDIR}'/tim-vx-imx'
SRCBRANCH='lf-5.15.52_2.1.0'
BUILD_NUM_JOBS=16
STAGING_BINDIR_NATIVE='/usr/bin'
TIM_VX_IMX_SRC='https://github.com/nxp-imx/tim-vx-imx.git'

pushd ${WORKDIR} && git clone -b ${SRCBRANCH} ${TIM_VX_IMX_SRC} ${S} && popd
pushd ${S} && cmake . -DTIM_VX_ENABLE_TEST=off -DTIM_VX_USE_EXTERNAL_OVXLIB=on -DOVXLIB_LIB=${D}${libdir}/libovxlib.so -DOVXLIB_INC=${D}${includedir}/OVXLIB && make -j`nproc` && make install && popd
#pushd ${S} && cmake . -DTIM_VX_ENABLE_TEST=off -DTIM_VX_USE_EXTERNAL_OVXLIB=on -DOVXLIB_LIB=/usr/lib/aarch64-linux-gnu/libovxlib.so -DOVXLIB_INC=/usr/include/aarch64-linux-gnu/OVXLIB && make -j`nproc` && make install && popd

cp ${S}/install/lib/libtim-vx.so ${D}${libdir}/libtim-vx.so
install -d ${D}${includedir}/tim
cp -r ${S}/install/include/tim/* ${D}${includedir}/tim
