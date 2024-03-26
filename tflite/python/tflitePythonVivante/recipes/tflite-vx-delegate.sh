#!/bin/bash
source global_variables.sh
PN='tensorflow-lite'
PV='2.9.1'
T=${WORKDIR}'/tensorflow-imx'
S=${WORKDIR}'/tflite-vx-delegate-imx'
SRCBRANCH='lf-5.15.71_2.2.0'
BUILD_NUM_JOBS=16
STAGING_BINDIR_NATIVE='/usr/bin'
VX_IMX_SRC='https://github.com/nxp-imx/tflite-vx-delegate-imx.git'
B='/tflite-vx-delegate-imx-build'

pushd ${WORKDIR} && git clone -b ${SRCBRANCH} ${VX_IMX_SRC} ${S} && popd
mkdir ${B}
cd ${B}
cmake ${S} \
        -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
        -DTIM_VX_INSTALL=${D}/usr \
        -DFETCHCONTENT_SOURCE_DIR_TENSORFLOW=${T} \
        -DTFLITE_LIB_LOC=${D}${libdir}/libtensorflow-lite.so 
make vx_delegate -j 16
#make . -j 16
make benchmark_model -j 16
make label_image -j 16
make install

# install libraries
install -d ${D}${libdir}
cp --no-preserve=ownership -d ${B}/libvx_delegate.so ${D}${libdir}
cp --no-preserve=ownership -d ${B}/libvx_custom_op.a ${D}${libdir}

cp ${B}/_deps/tensorflow-build/tools/benchmark/benchmark_model ${D}
cp ${B}/_deps/tensorflow-build/examples/label_image/label_image ${D}
# install header files
install -d ${D}${includedir}/tensorflow-lite-vx-delegate
cd ${S}
cp --parents \
    $(find . -name "*.h*") \
    ${D}${includedir}/tensorflow-lite-vx-delegate


