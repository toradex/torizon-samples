ARG BASE_NAME=wayland-base-vivante
ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

WORKDIR /home/torizon

#### INSTALL IMX-GPU-VIV DEPENDENCIES ####
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libgl-vivante1 \
    libopencl-vivante1 \
    libopencl-vivante1-dev \
    libclc-vivante1 \
    libgal-vivante1 \
    libvsc-vivante1 \
    && apt-get clean && apt-get autoremove

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    python3 python3-dev libatlas-base-dev \
    cmake build-essential gcc g++ git \
    && apt-get clean && apt-get autoremove

RUN apt-get install -y --no-install-recommends python3-pil python3-numpy python3-setuptools \
    && apt-get clean && apt-get autoremove

#### INSTALL QT DEPENDENCIES ####
RUN apt-get -y update && apt-get install -y --no-install-recommends libqt5gui5-gles libqt5quick5-gles \
    && apt-get clean && apt-get autoremove

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libqt5core5a libqt5dbus5  \
    libqt5network5 libqt5qml5 \
    && apt-get clean && apt-get autoremove

#### INSTALL GSTREAMER DEPENDENCIES ####

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libgstreamer1.0-0 gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x \
    gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 gstreamer1.0-pulseaudio \
    && apt-get clean && apt-get autoremove

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav v4l-utils python3-gst-1.0  \
    && apt-get clean && apt-get autoremove

#### INSTALL OPENCV DPENDENCIES ####
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libdc1394-22-dev \
    libdc1394-22-dev protobuf-compiler libgflags-dev libgoogle-glog-dev libblas-dev \
    libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev \
    libboost-dev libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev \
    && apt-get clean && apt-get autoremove

#### INSTALL OPENCV ####
RUN apt-get update && apt-get install -y --no-install-recommends python3-opencv \
    && apt-get clean && apt-get autoremove

RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    && apt-get clean && apt-get autoremove

#### INSTALL DLR ####
RUN git clone --recursive https://github.com/neo-ai/neo-ai-dlr.git -b v1.2.0

#### Required to workaround hash mismatch errors on slow connections ####
RUN sed -i 's/TIMEOUT 60/TIMEOUT 600/' neo-ai-dlr/cmake/Utils.cmake

RUN cd neo-ai-dlr || exit;mkdir build;cd build || exit;cmake ..;make -j"$(nproc)"
RUN cd neo-ai-dlr/python || exit;python3 setup.py install --user

#### Copy project files ####
RUN mkdir -p model
COPY model model
COPY inference.py .

ENTRYPOINT ["python3"]
CMD ["inference.py"]
