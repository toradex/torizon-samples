ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm64/v8
# For arm32 use:
# ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye
ARG PKG_ARCH=aarch64
# For arm32v7 use: 
# ARG PKG_ARCH=armv7l
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG
WORKDIR /home/torizon

ARG PKG_ARCH

# Install utils, app dependencies and TensorFlow Lite with APT
# https://www.tensorflow.org/lite/guide/python#install_tensorflow_lite_for_python
RUN apt-get -y update && apt-get install -y --no-install-recommends \
  curl unzip gnupg \
  && echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | \
    tee /etc/apt/sources.list.d/coral-edgetpu.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
  && apt-get -y update && apt-get install -y --no-install-recommends \
    python3-tflite-runtime \
    python3-pil \
  && apt-get remove gnupg \
  && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Anternative: Install utils and app dependencies with APT, Tensorflow Lite with PIP
# https://www.tensorflow.org/lite/guide/python#install_tensorflow_lite_for_python
#RUN apt-get -y update && apt-get install -y \
#  curl unzip \
#  python3-numpy \
#  python3-pil \
#  python3-pip \
#  && pip3 install --index-url https://google-coral.github.io/py-repo/ tflite_runtime \
#  && apt-get clean && apt-get autoremove

# Download the model
ENV MODEL_LINK https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_1.0_224_quant_and_labels.zip
RUN curl -o model.zip $MODEL_LINK && unzip model.zip && rm -rf __MACOSX model.zip

# Copy files
COPY image.jpg .
COPY main.py .

# Run script
ENTRYPOINT ["python3"]
CMD ["main.py"]
