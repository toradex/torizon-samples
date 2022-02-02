ARG CROSS_TC_IMAGE_ARCH=armhf
ARG CROSS_TC_DOCKER_REGISTRY=torizon
ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon

# First stage, x86_64 build container
FROM $CROSS_TC_DOCKER_REGISTRY/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH:$IMAGE_TAG AS cross-container
ARG GCC_PREFIX=arm-linux-gnueabihf
ARG CROSS_TC_IMAGE_ARCH

# install the libpiod development dependencies
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
    libgpiod-dev:$CROSS_TC_IMAGE_ARCH \
    libgpiod2:$CROSS_TC_IMAGE_ARCH \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy project source
WORKDIR /project
COPY . /project

# compile
RUN mkdir build && cd build \
    && $GCC_PREFIX-gcc -o gpio-toggle ../gpio-toggle.c -lgpiod \
    && $GCC_PREFIX-gcc -o gpio-event ../gpio-event.c -lgpiod

# Second stage, container for target
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG AS deploy-container

# To run examples we only need the libgpiod2 library. The gpiod package can
# be helpful for debugging.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libgpiod2 \
    gpiod \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# get the compiled program from the Build stage
COPY --from=cross-container /project/build/* /usr/local/bin/

# Use CMD to pass the GPIO bank line arguments
# Apalis iMX8 MXM3 pin 5 (Apalis GPIO3) is LSIO.GPIO0.IO12
# Apalis iMX6 MXM3 pin 5 (Apalis GPIO3) is GPIO2_IO6
CMD [ "/bin/bash" ]
