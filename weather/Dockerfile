# SDK container as base
ARG CROSS_TC_IMAGE_ARCH=armhf
ARG TOOLCHAIN_ARCH=armhf
ARG DOCKER_REGISTRY=torizon
ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=3-bookworm
ARG DOCKER_REGISTRY=torizon

FROM $DOCKER_REGISTRY/debian-cross-toolchain-$CROSS_TC_IMAGE_ARCH:$IMAGE_TAG AS build

ARG CROSS_TC_IMAGE_ARCH
ARG TOOLCHAIN_ARCH

WORKDIR /

# install all required development packages
COPY $TOOLCHAIN_ARCH-toolchain.cmake $TOOLCHAIN_ARCH-toolchain.cmake
RUN dpkg --add-architecture "$CROSS_TC_IMAGE_ARCH" \
    && apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    libcurl4-openssl-dev:$CROSS_TC_IMAGE_ARCH \
    libssl-dev:$CROSS_TC_IMAGE_ARCH \
    libboost-system-dev:$CROSS_TC_IMAGE_ARCH \
    libjsoncpp-dev:$CROSS_TC_IMAGE_ARCH \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Build cpr lib
COPY 0001-Remove-WError.patch .
RUN git clone https://github.com/libcpr/cpr.git \
    && mkdir cpr/build \
    && cd cpr/build \
    && EMAIL=root@localhost git am ../../0001-Remove-WError.patch \
    && cmake .. -DCMAKE_TOOLCHAIN_FILE=/$TOOLCHAIN_ARCH-toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCPR_USE_SYSTEM_CURL=ON \
    && cmake --build . \
    && cmake --install .

# Build influxdb lib
RUN git clone https://github.com/offa/influxdb-cxx.git \
    && mkdir influxdb-cxx/build \
    && cd influxdb-cxx/build \
    && cmake .. -DCMAKE_TOOLCHAIN_FILE=/$TOOLCHAIN_ARCH-toolchain.cmake \
        -DCMAKE_INSTALL_PREFIX=/usr -DINFLUXCXX_TESTING=OFF \
        -DINFLUXCXX_SYSTEMTEST=OFF \
    && make install

# build weather app
COPY src /src
RUN mkdir /src/build \
    && cd src/build \
    && cmake .. -DCMAKE_TOOLCHAIN_FILE=/$TOOLCHAIN_ARCH-toolchain.cmake \
    && make install

# create 2nd container for target
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

# install runtime libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4 \
    libssl3 \
    libjsoncpp25 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# take application executable from build container
COPY --from=build /usr/lib/libcpr.so* /usr/lib/
COPY --from=build /usr/lib/libInfluxDB.so* /usr/lib/
COPY --from=build /usr/bin/weather /usr/bin/

ENTRYPOINT [ "/usr/bin/weather" ]
