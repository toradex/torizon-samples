FROM torizon/arm64v8-debian-wayland-base-vivante
WORKDIR /home/torizon

#### INSTALL DEPENDENCIES ####
RUN apt-get -y update && apt-get install -y \
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

#### INSTALL OPENCV ####
RUN apt-get -y update && apt-get install -y \
    pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    libtbb2 libtbb-dev libjpeg-dev libpng-dev libdc1394-22-dev \
    libdc1394-22-dev protobuf-compiler libgflags-dev libgoogle-glog-dev libblas-dev \
    libhdf5-serial-dev liblmdb-dev libleveldb-dev liblapack-dev \
    libsnappy-dev libprotobuf-dev libopenblas-dev \
    libboost-dev libboost-all-dev libeigen3-dev libatlas-base-dev libne10-10 libne10-dev \
    && apt-get clean && apt-get autoremove

RUN git clone https://github.com/opencv/opencv.git
RUN cd opencv && git checkout 4.2.0 && mkdir -p build && cd build && cmake \
  -DWITH_OPENGL=ON -DWITH_TBB=ON -DWITH_PTHREADS_PF=ON  \
  -DCMAKE_BUILD_TYPE=RELEASE  -DWITH_OPENCL=ON -DWITH_CSTRIPES=ON \
  -DWITH_VULKAN=ON -DENABLE_PRECOMPILED_HEADERS=OFF \
	-DWITH_OPENVX=ON -DWITH_V4L=ON -DWITH_LIBV4L=ON \
	-DENABLE_NEON=ON -DENABLE_TBB=ON-DENABLE_IPP=ON -DENABLE_VFVP3=ON \
  ../ && make -j`nproc` && make install

#### INSTALL GSTREAMER ####
RUN apt-get -y update && apt-get install -y \
    libgstreamer1.0-0 gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x \
    gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio v4l-utils python3-gst-1.0 \
    && apt-get clean && apt-get autoremove

#### INSTALL DLR ####
RUN git clone --recursive https://github.com/neo-ai/neo-ai-dlr.git
RUN cd neo-ai-dlr;mkdir build;cd build;cmake ..;make -j`nproc`
RUN cd neo-ai-dlr/python;python3 setup.py install --user

# Install Flask
RUN apt-get -y update && apt-get install -y \
    python3-pip \
    && apt-get clean && apt-get autoremove

RUN pip3 install requests flask flask_restful flask_cors \
    && apt-get clean && apt-get autoremove

# Copy project files
RUN mkdir -p model
COPY model model
COPY inference.py .

ENTRYPOINT python3 inference.py
