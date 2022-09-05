ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS tflite-build

## Build tools
RUN apt-get -y update && apt-get install -y \
    cmake build-essential gcc g++ git wget unzip patchelf \
    autoconf automake libtool curl gfortran zlib1g

RUN git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name"

## Prepare the build environment ##
ENV CPATH="/build/usr/include/:${CPATH}"
ENV LIBRARY_PATH="/build/usr/lib/:${LIBRARY_PATH}"

## Install Python and TFLITE dependencies ##
RUN apt-get -y update && apt-get install -y --no-install-recommends \
  python3 python3-dev python3-setuptools \
  python3-wheel python3-pip libopenblas-dev \
  libjpeg-dev python3-pybind11 && \
  apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## NumPy 1.22.3 requires Cython >= 0.29.24
RUN wget https://snapshot.debian.org/archive/debian/20220612T214420Z/pool/main/c/cython/cython3_0.29.30-1_arm64.deb && apt-get install -y ./cython3_0.29.30-1_arm64.deb && rm -rf ./cython3_0.29.30-1_arm64.deb

WORKDIR /home/
COPY recipes /home/

### Build and install remaining libraries
###   This is necessary as the required libraries that enable the use of GPUs
###   and the iMX8MP NPU for machine learning are not yet available as debian packages
## Install imx-gpu-viv, including OpenVX 
RUN ./imx-gpu-viv_6.4.3.p1.4-aarch64.sh
## Install nn-imx
RUN ./nn-imx_1.3.0.sh
# Install Numpy
RUN ./python3-numpy_1.22.3.sh
# Workaround: After installing numpy whl, remove cpython*. More info: http://benno.id.au/blog/2013/01/15/python-determinism
RUN pip3 --no-cache-dir install /home/numpy-*.whl && \
  rm /usr/local/lib/python*/dist-packages/numpy/typing/tests/data/pass/__pycache__/literal.cpython*
## Install tensorflow-protobuf
RUN ./tensorflow-protobuf_3.9.2.sh
## Install tim-vx
RUN ./tim-vx_1.1.39.sh
## Install tensorflow-lite
RUN ./tensorflow-lite_2.8.0.sh
## Install tensorflow-lite-vx-delegate
RUN ./tensorflow-lite-vx-delegate_2.8.0.sh

############################################################
############ Build Application Container ###################
############################################################

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS tflite-base
COPY --from=tflite-build /out /
RUN ldconfig

RUN apt-get -y update && apt-get install -y --no-install-recommends \
  python3 python3-dev python3-setuptools \
  cython3 libopenblas-dev python3-wheel python3-pip \
  libjpeg-dev python3-pybind11 && \
  apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Workaround: After installing numpy whl, remove cpython*. More info: http://benno.id.au/blog/2013/01/15/python-determinism
RUN pip3 --no-cache-dir install /home/numpy-*.whl && \
  rm /usr/local/lib/python*/dist-packages/numpy/typing/tests/data/pass/__pycache__/literal.cpython*

RUN pip3 --no-cache-dir install /home/tflite_runtime-*.whl

RUN apt-get -y update && apt-get install -y --no-install-recommends python3-pil && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

### Install OpenCV Dependencies ###
RUN apt-get -y update && apt-get install -y --no-install-recommends --fix-missing \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libdc1394-22-dev \
    libdc1394-22-dev protobuf-compiler libgflags-dev libgoogle-glog-dev \
    libblas-dev libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev libboost-dev \
    libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## INSTALL OPENCV
RUN apt-get update && apt-get install -y --no-install-recommends python3-opencv && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

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
