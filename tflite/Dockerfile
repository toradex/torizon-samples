ARG ARCH_ARG=linux/arm64
# For arm32 use:
# ARG IMAGE_ARCH=linux/arm
ARG PKG_ARCH=aarch64
# For arm32v7 use: 
# ARG PKG_ARCH=armv7l

FROM --platform=$ARCH_ARG torizon/debian:1-buster
WORKDIR /home/torizon

ARG PKG_ARCH

## Install Python
RUN apt-get -y update && apt-get install -y \
  python3 \
  python3-dev \
  python3-numpy \
  python3-pil \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && apt-get clean && apt-get autoremove

## Install utils
RUN apt-get -y update && apt-get install -y \
  wget unzip \
  && apt-get clean && apt-get autoremove

# Install Tensorflow Lite
RUN wget https://dl.google.com/coral/python/tflite_runtime-2.1.0.post1-cp37-cp37m-linux_$PKG_ARCH.whl && pip3 install tflite_runtime-* && rm tflite_runtime-*

# Download the model
ENV MODEL_LINK https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_1.0_224_quant_and_labels.zip
RUN wget -O model.zip $MODEL_LINK && unzip model.zip && rm -rf __MACOSX model.zip

# Copy files
COPY image.jpg .
COPY main.py .

# Run script
ENTRYPOINT python3 main.py
