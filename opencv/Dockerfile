FROM torizon/wayland-base-vivante:1

WORKDIR /home/torizon

#### Install GPU Drivers ####
RUN apt-get -y update && apt-get install -y \
    libgl-vivante1 \
    libopencl-vivante1 \
    libopencl-vivante1-dev \
    libclc-vivante1 \
    libllvm-vivante1 \
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

ENV NO_AT_BRIDGE 1

#### Download a test image and run the cv2 application ####
RUN wget -O toradex_som.jpg https://docs.toradex.com/106926-verdin-imx8mm-front-view.jpg
COPY opencv-example.py .

ENTRYPOINT python3 opencv-example.py
