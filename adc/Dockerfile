ARG CROSS_TC_IMAGE_ARCH=armhf
ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye

# First stage, x86_64 build container
FROM torizon/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH:$IMAGE_TAG AS cross-container
ARG GCC_PREFIX=arm-linux-gnueabihf

# copy project source
WORKDIR /project
COPY adc/ /project

# compile
RUN mkdir build && cd build \
    && $GCC_PREFIX-gcc -Wall -g -D_GNU_SOURCE -o adc \
    ../iio_utils.c ../adc.c

# Second stage, container for target
FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG AS deploy-container

# get the compiled program from the Build stage
COPY --from=cross-container /project/build/* /usr/local/bin/

CMD adc
