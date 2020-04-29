ARG IMAGE_ARCH=arm32v7
ARG CROSS_TC_IMAGE_ARCH=armhf

# First stage, x86_64 build container
FROM torizon/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH AS cross-container

# copy project source
WORKDIR /project
COPY pwm/ /project

# compile
RUN mkdir build && cd build \
    && arm-linux-gnueabihf-gcc -o pwm ../pwm_utils.c ../pwm.c

# Second stage, container for target
FROM torizon/$IMAGE_ARCH-debian-base AS deploy-container

# get the compiled program from the Build stage
COPY --from=cross-container /project/build/* /usr/local/bin/

CMD pwm
