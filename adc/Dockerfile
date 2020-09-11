ARG IMAGE_ARCH=arm32v7
ARG CROSS_TC_IMAGE_ARCH=armhf
ARG ARCH_ARG=linux/arm
ARG IMAGE_TAG=1-buster

# First stage, x86_64 build container
FROM torizon/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH:1 AS cross-container

# copy project source
WORKDIR /project
COPY adc/ /project

# compile
RUN mkdir build && cd build \
    && arm-linux-gnueabihf-gcc -Wall -g -D_GNU_SOURCE -o adc \
    ../iio_utils.c ../adc.c

# Second stage, container for target
FROM --platform=$ARCH_ARG torizon/debian:$IMAGE_TAG AS deploy-container

# get the compiled program from the Build stage
COPY --from=cross-container /project/build/* /usr/local/bin/

CMD adc