ARG IMAGE_ARCH=arm32v7
# For Apalis iMX8 use IMAGE_ARCH=arm64v8

FROM torizon/$IMAGE_ARCH-debian-base:buster

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    python3-setuptools \
    python3-influxdb \
    wait-for-it \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY sht31module sht31module
RUN  cd sht31module && python3 setup.py install

COPY sht31-influxdb.py /usr/bin
