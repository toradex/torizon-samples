ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=3-bookworm
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

# install required packages
RUN apt-get -q -y update && apt-get -q -y install --no-install-recommends \
    python3 \
    dbus \
    libdbus-1-dev \
    libglib2.0 \
    libglib2.0-dev && \
    rm -rf /var/lib/apt/lists/*

# adds the sample scripts
WORKDIR /root
COPY dbus-sample.py /root/dbus-sample.py
COPY list-system-services.py /root/list-system-services.py
COPY list-ip-addresses.py /root/list-ip-addresses.py

# runs python interpreter as main process
CMD ["python3"]

