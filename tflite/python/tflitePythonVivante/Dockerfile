# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=
# For armv7 use:
#ARG IMAGE_ARCH=arm

##
# Base container version
##
ARG BASE_VERSION=3.3.0-bookworm

ARG APP_ROOT=

FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS Build

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ARG APP_ROOT
ARG BASE_VERSION

## Install Python
RUN apt-get -y update && apt-get install -y \
  python3 python3-dev python3-numpy python3-pybind11 \
  python3-pip python3-setuptools python3-wheel \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install build tools
RUN apt-get -y update && apt-get install -y \
    cmake build-essential gcc g++ git wget unzip patchelf \
    autoconf automake libtool curl gfortran && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install dependencies
RUN apt-get -y update && apt-get install -y \
    zlib1g zlib1g-dev libssl-dev \
    imx-gpu-viv-wayland-dev openssl libffi-dev libjpeg-dev && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY recipes /build

### Install TensorFlow Lite
RUN ./nn-imx_1.3.0.sh
RUN ./tim-vx.sh
RUN ./tensorflow-lite_2.9.1.sh
RUN ./tflite-vx-delegate.sh

############################################################
############ Build Application Container ###################
############################################################

FROM --platform=linux/$IMAGE_ARCH torizon/debian:${BASE_VERSION} AS Deploy

## Install Python
RUN apt-get -y update && apt-get install -y \
  python3-venv \
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*


# Create virtualenv
RUN python3 -m venv ${APP_ROOT}/.venv --system-site-packages

# Install pip packages on venv
COPY requirements-release.txt /requirements-release.txt
RUN . ${APP_ROOT}/.venv/bin/activate && \
    pip3 install --upgrade pip && pip3 install --break-system-packages -r requirements-release.txt && \
    rm requirements-release.txt

## Install TF Lite ##
COPY --from=Build /build /build
RUN cp -r /build/* /
RUN . ${APP_ROOT}/.venv/bin/activate && \
    pip3 install --break-system-packages --no-cache-dir /tflite_runtime-*.whl && rm -rf *.whl

## Install runtime TF Lite dependencies ## 
RUN apt-get -y update && apt-get install -y \
    libovxlib \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install application dependencies
RUN apt-get -y update && apt-get install -y \
  wget unzip imx-gpu-viv-wayland-dev \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the source code
COPY /src ${APP_ROOT}/src

WORKDIR ${APP_ROOT}

ENV APP_ROOT=${APP_ROOT}
# Activate and run the code
CMD . ${APP_ROOT}/.venv/bin/activate && python3 src/main.py --no-sandbox