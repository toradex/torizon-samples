ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

WORKDIR /home/torizon

#### Install GPU Drivers ####
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libgl-vivante1 \
    libopencl-vivante1 \
    libopencl-vivante1-dev \
    libclc-vivante1 \
    libgal-vivante1 \
    libvsc-vivante1 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

#### Install Python and other utilities ####
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    python3 wget \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

#### Install OpenCV Dependencies ####
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libdc1394-22-dev \
    libdc1394-22-dev protobuf-compiler libgflags-dev libgoogle-glog-dev \
    libblas-dev libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev libboost-dev \
    libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

#### INSTALL OPENCV ####
RUN apt-get update && apt-get install -y --no-install-recommends python3-opencv \
    && rm -rf /var/lib/apt/lists/*

ENV NO_AT_BRIDGE 1

#### Download a test image and run the cv2 application ####
RUN wget -q -O toradex_som.jpg https://docs.toradex.com/106926-verdin-imx8mm-front-view.jpg
COPY opencv-example.py .

ENTRYPOINT ["python3"]
CMD ["opencv-example.py"]
