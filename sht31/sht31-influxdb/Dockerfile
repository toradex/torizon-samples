ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm
# For Apalis iMX8 use IMAGE_ARCH=linux/arm64
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    python3-setuptools \
    python3-influxdb \
    wait-for-it \
    python3-pip \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY sht31module /sht31module
RUN  cd sht31module && python3 setup.py install

COPY sht31-influxdb.py /usr/bin

RUN pip3 install --no-cache-dir pyserial pynmea2
COPY gps/gps.py /usr/bin
