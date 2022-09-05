#!/bin/bash
set -e
source build_variables.sh `basename "$0"`
THIS_DIR=$(cd $(dirname $0) && pwd)
SRC_URI="https://github.com/numpy/numpy.git"
SRCBRANCH="main"
PYTHON_SITEPACKAGES_DIR="/usr/local/lib/python3.9/dist-packages/"

SRCNAME="numpy"

pushd ${WORKDIR} && \
  wget https://github.com/${SRCNAME=}/${SRCNAME}/releases/download/v${PV}/${SRCNAME}-${PV}.tar.gz -O ${SRCNAME}.tar.gz && \
  tar -zxf ./${SRCNAME}.tar.gz && \
  mkdir -p ${S} && cp -r numpy-${PV}/* ${S} && \
  popd

  pushd ${S} && \
    BLAS="/usr/lib/aarch64-linux-gnu/" NPY_DISABLE_SVML=1 python3 setup.py \
      build -j `nproc` --build-base ${B} \
      egg_info --egg-base ${B} \
      bdist_wheel && \
  popd

  install -d ${D}/home
  cp ${S}/dist/numpy-*.whl ${D}/home/

# Copy installed libraries to rootfs #
cp -r ${D}/* /
# Reload libraries #
ldconfig
# Clean build directory #
rm -rf ${WORKDIR}
