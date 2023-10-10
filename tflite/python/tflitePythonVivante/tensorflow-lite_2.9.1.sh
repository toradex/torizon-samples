#!/bin/bash
source global_variables.sh
PN='tensorflow-lite'
PV='2.9.1'
S=${WORKDIR}'/tensorflow-imx'
SRCBRANCH='lf-5.15.52_2.1.0'
PYTHON_DIR='/usr/lib/python3.11'
PYTHON_SITEPACKAGES_DIR=${PYTHON_DIR}'/site-packages'
BUILD_NUM_JOBS=16
B='/tflite-build'
B2='/tflite-build-tools'

## Get Tensorflow Code ##
git clone -b $SRCBRANCH https://github.com/nxp-imx/tensorflow-imx.git ${S}

## do_compile_append ##
mkdir ${B2}
cd ${B2}
cmake ${S}/tensorflow/lite/tools/cmake/native_tools
cmake --build . -j ${BUILD_NUM_JOBS}
make install DESTDIR=${D}

mkdir ${B}
cd ${B}
#cmake ${S}/tensorflow/lite \
cmake \
    -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
    -DTFLITE_BUILD_SHARED_LIB=on \
    -DTFLITE_ENABLE_NNAPI=off \
    -DTFLITE_ENABLE_NNAPI_VERBOSE_VALIDATION=on \
    -DTFLITE_ENABLE_RUY=on \
    -DTFLITE_ENABLE_XNNPACK=on \
    -DTFLITE_PYTHON_WRAPPER_BUILD_CMAKE2=on \
    -DTFLITE_ENABLE_EXTERNAL_DELEGATE=on \
    ${S}/tensorflow/lite \

cmake --build . -j ${BUILD_NUM_JOBS}
#cmake --build . -j ${BUILD_NUM_JOBS} -t benchmark_model
#cmake --build . -j ${BUILD_NUM_JOBS} -t label_image
# cmake --install .

## get models ##
wget https://storage.googleapis.com/download.tensorflow.org/models/mobilenet_v1_2018_08_02/mobilenet_v1_1.0_224_quant.tgz
mkdir -p ${WORKDIR}/model;tar zxvf mobilenet_v1_1.0_224_quant.tgz -C ${WORKDIR}/model;rm mobilenet_v1_1.0_224_quant.tgz

# install libraries
install -d ${D}${libdir}
#for lib in ${B}/libtensorflow-lite.so*
#do
#    cp --no-preserve=ownership -d $lib ${D}${libdir}
#done

cp --no-preserve=ownership -d ${B}/libtensorflow-lite.so.2.9.1 ${D}${libdir}/libtensorflow-lite.so

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
cp ${WORKDIR}/model/mobilenet_v1_1.0_224_quant.tflite ${D}${bindir}/${PN}-${PV}/examples

install -d ${D}${libdir}/pkgconfig
install -m 0644 ${WORKDIR}/tensorflow-lite.pc.in ${D}${libdir}/pkgconfig/tensorflow2-lite.pc

sed -i 's:@version@:${PV}:g
    s:@libdir@:${libdir}:g
    s:@includedir@:${includedir}:g' ${D}${libdir}/pkgconfig/tensorflow2-lite.pc

cd ${B}
BUILD_NUM_JOBS=${BUILD_NUM_JOBS} ${S}/tensorflow/lite/tools/pip_package/build_pip_package_with_cmake2.sh
cp ${B}/tflite_pip/dist/tflite_runtime-2.9.1-cp311-cp311-linux_aarch64.whl ${D}/tflite_runtime-2.9.1-cp311-cp311-linux_aarch64.whl
# # Install pip package
# install -d ${D}/${PYTHON_SITEPACKAGES_DIR}
# ${STAGING_BINDIR_NATIVE}/pip3 install --disable-pip-version-check -v \
#     -t ${D}/${PYTHON_SITEPACKAGES_DIR} --no-cache-dir --no-deps \
#     ${WORKDIR}/tflite_pip/dist/tflite_runtime-*.whl
