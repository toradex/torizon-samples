FROM torizon/arm64v8-debian-wayland-base-vivante

WORKDIR /home/torizon

#### INSTALL IMX-GPU-VIV DEPENDENCIES ####
RUN apt-get -y update && apt-get install -y \
    libgl-vivante1 \
    libopencl-vivante1 \
    libopencl-vivante1-dev \
    libclc-vivante1 \
    libllvm-vivante1 \
    libgal-vivante1 \
    libvsc-vivante1 \
    && apt-get clean && apt-get autoremove

RUN apt-get -y update && apt-get install -y \
    python3 python3-dev libatlas-base-dev \
    cmake build-essential gcc g++ git \
    && apt-get clean && apt-get autoremove

RUN apt-get install -y python3-pil python3-numpy python3-setuptools \
    && apt-get clean && apt-get autoremove

#### INSTALL QT DEPENDENCIES ####
RUN apt-get -y update && apt-get install -y \
    libqt5core5a-vivante libqt5dbus5-vivante libqt5gui5-vivante \
    libqt5network5-vivante libqt5qml5-vivante libqt5quick5-vivante \
    && apt-get clean && apt-get autoremove

#### INSTALL GSTREAMER DEPENDENCIES ####
RUN apt-get -y update && apt-get install -y \
    libgstreamer1.0-0-imx gstreamer1.0-plugins-base-imx \
    gstreamer1.0-plugins-good-imx gstreamer1.0-plugins-bad-imx \
     gstreamer1.0-imx-doc gstreamer1.0-tools-imx gstreamer1.0-x-imx \
    gstreamer1.0-alsa-imx gstreamer1.0-gl-imx gstreamer1.0-gtk3-imx \
    gstreamer1.0-qt5-imx gstreamer1.0-pulseaudio-imx \
    && apt-get clean && apt-get autoremove

RUN apt-get -y update && apt-get install -y \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav v4l-utils python3-gst-1.0  \
    && apt-get clean && apt-get autoremove

#### INSTALL OPENCV DPENDENCIES ####
RUN apt-get -y update && apt-get install -y \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libdc1394-22-dev \
    libdc1394-22-dev protobuf-compiler libgflags-dev libgoogle-glog-dev libblas-dev \
    libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev \
    libboost-dev libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev \
    && apt-get clean && apt-get autoremove

#### INSTALL OPENCV ####
RUN apt-get update && apt-get install -y libopencv4.2-java libopencv4.2-jni \
    libopencv-calib3d4.2 libopencv-calib3d-dev libopencv-contrib4.2 \
    libopencv-contrib-dev libopencv-core4.2 libopencv-core-dev libopencv-dev \
    libopencv-dnn4.2 libopencv-dnn-dev libopencv-features2d4.2 \
    libopencv-features2d-dev libopencv-flann4.2 libopencv-flann-dev \
    libopencv-gapi4.2 libopencv-gapi-dev \
    libopencv-highgui4.2 libopencv-highgui-dev libopencv-imgcodecs4.2 \
    libopencv-imgcodecs-dev libopencv-imgproc4.2 libopencv-imgproc-dev \
    libopencv-ml4.2 libopencv-ml-dev libopencv-objdetect4.2 \
    libopencv-objdetect-dev libopencv-photo4.2 libopencv-photo-dev \
    libopencv-shape4.2 libopencv-shape-dev libopencv-stitching4.2 \
    libopencv-stitching-dev libopencv-superres4.2 libopencv-superres-dev \
    libopencv-video4.2 libopencv-video-dev libopencv-videoio4.2 \
    libopencv-videoio-dev libopencv-videostab4.2 libopencv-videostab-dev \
    libopencv-viz4.2 libopencv-viz-dev opencv-data opencv-doc python3-opencv \
    && apt-get clean && apt-get autoremove

#### INSTALL DLR ####
RUN git clone --recursive https://github.com/neo-ai/neo-ai-dlr.git
RUN cd neo-ai-dlr;mkdir build;cd build;cmake ..;make -j`nproc`
RUN cd neo-ai-dlr/python;python3 setup.py install --user

# Copy project files
RUN mkdir -p model
COPY model model
COPY inference.py .

ENTRYPOINT python3 inference.py
