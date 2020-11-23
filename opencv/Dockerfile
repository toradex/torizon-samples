FROM torizon/wayland-base-vivante:2

WORKDIR /home/torizon

#### Install GPU Drivers ####
RUN apt-get -y update && apt-get install -y \
    libgl-vivante1 \
    libopencl-vivante1 \
    libopencl-vivante1-dev \
    libclc-vivante1 \
    libgal-vivante1 \
    libvsc-vivante1 \
    && apt-get clean && apt-get autoremove

#### Install Python and other utilities ####
RUN apt-get -y update && apt-get install -y \
    python3 wget \
    && apt-get clean && apt-get autoremove

#### Install OpenCV Dependencies ####
RUN apt-get -y update && apt-get install -y \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libdc1394-22-dev \
    libdc1394-22-dev protobuf-compiler libgflags-dev libgoogle-glog-dev \
    libblas-dev libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev libboost-dev \
    libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev \
    && apt-get clean && apt-get autoremove

#### INSTALL OPENCV ####
RUN apt-get update && apt-get install -y python3-opencv

ENV NO_AT_BRIDGE 1

#### Download a test image and run the cv2 application ####
RUN wget -O toradex_som.jpg https://docs.toradex.com/106926-verdin-imx8mm-front-view.jpg
COPY opencv-example.py .

ENTRYPOINT python3 opencv-example.py
