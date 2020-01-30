ARG IMAGE_ARCH=arm32v7
# For Apalis iMX8 use IMAGE_ARCH=arm64v8

FROM torizon/$IMAGE_ARCH-debian-base:buster

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    python3-setuptools \
    python3-flask \
    python3-influxdb \
    wait-for-it \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN mkdir flaskapp
COPY flaskapp.py flaskapp/
COPY templates/ flaskapp/templates/
COPY static/ flaskapp/static/
