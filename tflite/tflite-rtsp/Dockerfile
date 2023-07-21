ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=3-bookworm
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS tflite-build

## Install Python
RUN apt-get -y update && apt-get install -y \
  python3 python3-dev python3-numpy python3-pybind11 \
  python3-pip python3-setuptools python3-wheel \
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install build tools
RUN apt-get -y update && apt-get install -y \
    cmake build-essential gcc g++ git wget unzip patchelf \
    autoconf automake libtool curl gfortran

## Install dependencies
RUN apt-get -y update && apt-get install -y \
    zlib1g zlib1g-dev libssl-dev \
    imx-gpu-viv-wayland-dev openssl libffi-dev libjpeg-dev

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

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS tflite-base

## Install Python
RUN apt-get -y update && apt-get install -y \
  python3 python3-dev python3-numpy python3-pybind11 \
  python3-pip python3-setuptools python3-wheel \
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install TF Lite ##
COPY --from=tflite-build /build /build
RUN cp -r /build/* /
RUN pip3 install --break-system-packages --no-cache-dir /tflite_runtime-*.whl && rm -rf *.whl

## Install runtime TF Lite dependencies ## 
RUN apt-get -y update && apt-get install -y \
    libovxlib

## Install application dependencies
RUN apt-get -y update && apt-get install -y \
  wget unzip python3-pil imx-gpu-viv-wayland-dev \
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install OpenCV
RUN apt-get -y update && apt-get install -y --no-install-recommends  \
    python3-opencv \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

#### Install OpenCV Dependencies ####
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbbmalloc2 libtbb-dev libjpeg-dev libpng-dev libdc1394-25 \
    libdc1394-dev protobuf-compiler libgflags-dev libgoogle-glog-dev \
    libblas-dev libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev libboost-dev \
    libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Install GStreamer and rtsp libraries
RUN apt-get -y update && apt-get install -y --no-install-recommends libgstreamer1.0-0 \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-tools gstreamer1.0-OpenCV \
    python3-gst-1.0 gstreamer1.0-rtsp libgstrtspserver-1.0-0 gir1.2-gst-rtsp-server-1.0 && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## Copy demos to working directory
WORKDIR /home
COPY demos .

## Setup startup program
WORKDIR /home/object-detection

# Run script
ENTRYPOINT ["python3"]
CMD ["object-detection.py"]

