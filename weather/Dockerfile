# SDK container as base
ARG CROSS_TC_IMAGE_ARCH=armhf
ARG TOOLCHAIN_ARCH=armhf
ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye

FROM torizon/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH:$IMAGE_TAG AS build

ARG CROSS_TC_IMAGE_ARCH
ARG TOOLCHAIN_ARCH

RUN echo "dpkg --add-architecture $CROSS_TC_IMAGE_ARCH"
RUN dpkg --add-architecture "$CROSS_TC_IMAGE_ARCH"

# install all required development packages
RUN apt-get update
RUN apt-get install -y git \
    cmake \
    libcurl4-openssl-dev:$CROSS_TC_IMAGE_ARCH \
    libboost1.71-dev:$CROSS_TC_IMAGE_ARCH \
    libboost-system1.71-dev:$CROSS_TC_IMAGE_ARCH \
    libboost-test1.71-dev:$CROSS_TC_IMAGE_ARCH \
    libboost-program-options1.71-dev:$CROSS_TC_IMAGE_ARCH \
    libjsoncpp-dev:$CROSS_TC_IMAGE_ARCH \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Build influxdb lib
RUN git clone https://github.com/awegrzyn/influxdb-cxx.git
COPY $TOOLCHAIN_ARCH-toolchain.cmake $TOOLCHAIN_ARCH-toolchain.cmake
RUN mkdir influxdb-cxx/build
RUN cd influxdb-cxx/build && cmake .. -DCMAKE_TOOLCHAIN_FILE=/$TOOLCHAIN_ARCH-toolchain.cmake \
    -DCMAKE_INSTALL_PREFIX=/usr
RUN cd influxdb-cxx/build && make install

# build weather app
COPY src src
RUN mkdir /src/build
RUN cd src/build && cmake .. -DCMAKE_TOOLCHAIN_FILE=/$TOOLCHAIN_ARCH-toolchain.cmake
RUN cd src/build && make install

# create 2nd container for target
FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG

# install runtime libraries
RUN apt-get update
RUN apt-get install -y libcurl4 libboost-system1.71.0 libjsoncpp1 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# take application executable from build container
COPY --from=build /usr/lib/libInfluxDB.so /usr/lib
COPY --from=build /usr/bin/weather /usr/bin/

ENTRYPOINT [ "/usr/bin/weather" ]
