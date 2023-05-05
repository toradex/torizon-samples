ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm64/v8
# For arm32 use:
# ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=3-bookworm
ARG PKG_ARCH=aarch64
# For arm32v7 use: 
# ARG PKG_ARCH=armv7l
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG
WORKDIR /home/torizon

ARG PKG_ARCH

RUN apt-get -y update && apt-get install -y --no-install-recommends \
  libssl-dev openssl libffi-dev wget build-essential zlib1g-dev unzip libjpeg-dev curl

# Install Python from source, as tflite doesn't support the default python version that ships with Bookworm
WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz \
    && tar -xvf Python-3.9.0.tgz \
    && cd Python-3.9.0 && ./configure --enable-optimizations --prefix=/usr/local && make && make install \
    && ln -sf /usr/local/bin/python3.9 /usr/local/bin/python \
    && ln -sf /usr/local/bin/pip3.0 /usr/local/bin/pip 

# Install utils and app dependencies with APT, Tensorflow Lite with PIP
# https://www.tensorflow.org/lite/guide/python#install_tensorflow_lite_for_python
RUN /usr/local/bin/python -m pip install numpy Pillow \
    && /usr/local/bin/python -m pip install --index-url https://google-coral.github.io/py-repo/ tflite_runtime \
    && apt-get clean \
    && apt-get autoremove

WORKDIR /home/torizon

# Download the model
ENV MODEL_FILENAME mobilenet_v1_1.0_224_quant_and_labels.zip
ENV MODEL_LINK https://storage.googleapis.com/download.tensorflow.org/models/tflite/$MODEL_FILENAME
RUN wget $MODEL_LINK && mv $MODEL_FILENAME model.zip && unzip model.zip && rm -rf __MACOSX model.zip

# Copy files
COPY image.jpg .
COPY main.py .

# Run script
ENTRYPOINT ["python3"]
CMD ["main.py"]
