ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_ARCH=linux/arm64
ARG IMAGE_TAG=3
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS framos-build

ARG ISP_IMX_VERSION="4.2.2.20.0"
ARG ACCEPT_FSL_EULA=1
ARG ISP_IMX_URL="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/isp-imx-$ISP_IMX_VERSION.bin"

## Install build dependencies

RUN apt-get -y update && apt-get install -y \
    cmake build-essential gcc g++ git wget unzip patchelf \
    autoconf automake libtool curl gfortran libboost-all-dev \
    libwayland-dev libdrm-dev libg2d-dpu-dev libg2d-dpu \
    libtinyxml2-dev linux-imx-headers-dev patch kmod

# Create Symlinks for libraries

RUN ln -s /usr/lib/aarch64-linux-gnu/libtinyxml2.so /usr/lib/libtinyxml2.so
RUN ln -s /usr/include/libdrm /usr/include/drm

WORKDIR downloads

# download and extract isp-imx from NXP site

RUN wget -O isp-imx-$ISP_IMX_VERSION.bin $ISP_IMX_URL
RUN chmod +x isp-imx-$ISP_IMX_VERSION.bin
RUN ./isp-imx-$ISP_IMX_VERSION.bin --auto-accept --force

# apply patches for framos cameras

COPY patches/ /downloads/isp-imx-$ISP_IMX_VERSION/patches

WORKDIR /downloads/isp-imx-$ISP_IMX_VERSION/patches
RUN ./patch.sh

# build isp-imx

WORKDIR /downloads/isp-imx-$ISP_IMX_VERSION/
RUN ./build-all-isp.sh Release v4l2

# apply patch to use bash instead of sh in some isp scripts
WORKDIR /downloads/isp-imx-$ISP_IMX_VERSION/patches
RUN ./sed-bash.sh

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS framos-base

ARG ISP_IMX_VERSION=4.2.2.20.0
ARG ACCEPT_FSL_EULA=1
ARG SRC_DIR=/downloads/isp-imx-${ISP_IMX_VERSION}
ARG BUILD_DIR=${SRC_DIR}/build_output_release_v4l2
ARG INSTALL_DIR=/build-isp-imx/opt/imx8-isp

WORKDIR /build-isp-imx/opt/imx8-isp/
RUN mkdir -p /build-isp-imx/opt/imx8-isp/bin
RUN mkdir -p /build-isp-imx/opt/imx8-isp/bin/dewarp_config
RUN mkdir -p /build-isp-imx/opt/imx8-isp/lib
RUN mkdir -p /build-isp-imx/opt/imx8-isp/include

RUN apt-get -y update && apt-get install -y tree kmod libtinyxml2-dev procps

## Copy compiled binaries, libraries, and other files
COPY --from=framos-build /downloads/isp-imx-$ISP_IMX_VERSION/build_output_release_v4l2/opt/imx8-isp/bin/video_test /build-isp-imx/opt/imx8-isp/bin
COPY --from=framos-build /downloads/isp-imx-$ISP_IMX_VERSION/build_output_release_v4l2/opt/imx8-isp/bin/IMX*.xml /build-isp-imx/opt/imx8-isp/bin/
COPY --from=framos-build /downloads/isp-imx-$ISP_IMX_VERSION/build_output_release_v4l2/opt/imx8-isp/bin/imx*.drv /build-isp-imx/opt/imx8-isp/bin/
COPY --from=framos-build $SRC_DIR/dewarp/dewarp_config/ $INSTALL_DIR/bin/dewarp_config
COPY --from=framos-build $BUILD_DIR/opt/imx8-isp/bin/isp_media_server $INSTALL_DIR/bin
COPY --from=framos-build $BUILD_DIR/opt/imx8-isp/bin/vvext $INSTALL_DIR/bin
COPY --from=framos-build $BUILD_DIR/usr/lib/ $INSTALL_DIR/lib/
RUN cp $INSTALL_DIR/lib/lib*.so* /usr/lib/

# Copy any extra scripts from source
COPY --from=framos-build $BUILD_DIR/opt/imx8-isp/bin/start_isp.sh $INSTALL_DIR/bin
COPY --from=framos-build $BUILD_DIR/opt/imx8-isp/bin/run.sh $INSTALL_DIR/bin
RUN chmod +x $INSTALL_DIR/bin/run.sh $INSTALL_DIR/bin/start_isp.sh