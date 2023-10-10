#!/bin/bash
source global_variables.sh
PN='nn-imx'
PV='1.3.0'
S=${WORKDIR}'/'${PN}
SRCBRANCH='imx_1.3.0'
STAGING_BINDIR_NATIVE='/usr/bin'
NN_IMX_SRC='https://github.com/nxp-imx/nn-imx.git'

pushd ${WORKDIR} && git clone -b ${SRCBRANCH} ${NN_IMX_SRC} ${S} && popd
pushd ${S} && AQROOT=${S} make -j`nproc` && popd

## do_install () ##
install -d ${D}${libdir}
install -d ${D}${includedir}/OVXLIB
install -d ${D}${includedir}/nnrt
cp -d ${S}/*.so* ${D}${libdir}
cp -r ${S}/include/OVXLIB/* ${D}/${includedir}/OVXLIB
cp -r ${S}/include/nnrt/* ${D}/${includedir}/nnrt

