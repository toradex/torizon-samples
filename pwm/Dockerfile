ARG CROSS_TC_IMAGE_ARCH=armhf
ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye

# First stage, x86_64 build container
FROM torizon/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH:$IMAGE_TAG AS cross-container

# copy project source
WORKDIR /project
COPY pwm/ /project

ARG GCC_PREFIX=arm-linux-gnueabihf
# compile
RUN mkdir build && cd build \
    && $GCC_PREFIX-gcc -o pwm ../pwm_utils.c ../pwm.c

# Second stage, container for target
FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG AS deploy-container

# get the compiled program from the Build stage
COPY --from=cross-container /project/build/* /usr/local/bin/

CMD pwm
