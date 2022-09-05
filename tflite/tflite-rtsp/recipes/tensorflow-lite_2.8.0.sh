#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
THIS_DIR=$(cd $(dirname $0) && pwd)
SRC_URI="git://source.codeaurora.org/external/imx/tensorflow-imx.git"
SRCBRANCH="lf-5.15.32_2.0.0"
SRCREV="9f93a90ef0577204787bd8bb1ca75cd46902ab64"
PKG_CONFIG_SYSROOT_DIR="/"
EXTRA_OECMAKE+=" \
  -DCMAKE_SYSROOT=${PKG_CONFIG_SYSROOT_DIR} \
  -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
  -DTFLITE_EVAL_TOOLS=on \
  -DTFLITE_HOST_TOOLS_DIR=${STAGING_BINDIR_NATIVE} \
  -DTFLITE_BUILD_SHARED_LIB=on \
  -DTFLITE_ENABLE_NNAPI=off \
  -DTFLITE_ENABLE_NNAPI_VERBOSE_VALIDATION=on \
  -DTFLITE_ENABLE_RUY=on \
  -DTFLITE_ENABLE_XNNPACK=on \
  -DTFLITE_PYTHON_WRAPPER_BUILD_CMAKE2=on \
  -DTFLITE_ENABLE_EXTERNAL_DELEGATE=on \
  ${S}/tensorflow/lite/ \
"

## Get Tensorflow Code ##
pushd ${WORKDIR} && \
  git clone -b ${SRCBRANCH} ${SRC_URI} ${S} && \
  wget https://storage.googleapis.com/download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_224_quant.tgz && \
  tar zxvf mobilenet_v1_1.0_224_quant.tgz && \
  popd

pushd ${S} && \
  git reset ${SRCREV} --hard && \
  git clean -df && \
  git submodule update --init --recursive && \
  popd

### Build ###
mkdir -p ${B} && \
pushd ${B} && \
  cmake ${EXTRA_OECMAKE} .. && \
  make -j`nproc` all install && \
popd

### do_compile_append () ###
pushd ${B} && \
  CI_BUILD_PYTHON=python3 BUILD_NUM_JOBS=8 ${S}/tensorflow/lite/tools/pip_package/build_pip_package_with_cmake2.sh arm64
popd

### do_install() ###
# install libraries
install -d ${D}${libdir}
for lib in ${B}/lib*.so*
do
    cp --no-preserve=ownership -d $lib ${D}${libdir}
done

# install header files
install -d ${D}${includedir}/tensorflow/lite
cd ${S}/tensorflow/lite
cp --parents \
    $(find . -name "*.h*") \
    ${D}${includedir}/tensorflow/lite

# install version.h from core
install -d ${D}${includedir}/tensorflow/core/public
cp ${S}/tensorflow/core/public/version.h ${D}${includedir}/tensorflow/core/public

# install examples
install -d ${D}${bindir}/${PN}-${PV}/examples
install -m 0555 ${B}/examples/label_image/label_image ${D}${bindir}/${PN}-${PV}/examples
install -m 0555 ${B}/tools/benchmark/benchmark_model ${D}${bindir}/${PN}-${PV}/examples
install -m 0555 ${B}/tools/evaluation/coco_object_detection_run_eval ${D}${bindir}/${PN}-${PV}/examples
install -m 0555 ${B}/tools/evaluation/imagenet_image_classification_run_eval ${D}${bindir}/${PN}-${PV}/examples
install -m 0555 ${B}/tools/evaluation/inference_diff_run_eval ${D}${bindir}/${PN}-${PV}/examples

# install label_image data
cp ${S}/tensorflow/lite/examples/label_image/testdata/grace_hopper.bmp ${D}${bindir}/${PN}-${PV}/examples
cp ${S}/tensorflow/lite/java/ovic/src/testdata/labels.txt ${D}${bindir}/${PN}-${PV}/examples


# Install python example
cp ${S}/tensorflow/lite/examples/python/label_image.py ${D}${bindir}/${PN}-${PV}/examples

# Install mobilenet tflite file
cp ${WORKDIR}/mobilenet_*.tflite ${D}${bindir}/${PN}-${PV}/examples

# Install pip package
cp ${B}/tflite_pip/dist/tflite_runtime-*.whl ${D}/home/

## do_install_append() ##
install -d ${D}${libdir}/pkgconfig
install -m 0644 ${THIS_DIR}/${PN}-patch/tensorflow-lite.pc.in ${D}${libdir}/pkgconfig/tensorflow2-lite.pc

sed -i 's:@version@:${PV}:g
    s:@libdir@:${libdir}:g
    s:@includedir@:${includedir}:g' ${D}${libdir}/pkgconfig/tensorflow2-lite.pc

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
