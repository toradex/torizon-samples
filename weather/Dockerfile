# SDK container as base
ARG TOOLCHAIN_ARCH
ARG IMAGE_ARCH
FROM torizon/debian-cross-toolchain-$TOOLCHAIN_ARCH:latest AS build

ARG TOOLCHAIN_ARCH
ARG PKG_ARCH

RUN echo "dpkg --add-architecture $PKG_ARCH"
RUN dpkg --add-architecture "$PKG_ARCH"

# install all required development packages
RUN apt-get update
RUN apt-get install -y git \
    cmake \
    libcurl4-openssl-dev:$PKG_ARCH \
    libboost1.67-dev:$PKG_ARCH \
    libboost-system1.67-dev:$PKG_ARCH \
    libboost-test1.67-dev:$PKG_ARCH \
    libboost-program-options1.67-dev:$PKG_ARCH \
    libjsoncpp-dev:$PKG_ARCH \
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
FROM torizon/$IMAGE_ARCH-debian-base:latest

# install runtime libraries
RUN apt-get update
RUN apt-get install -y libcurl4 libboost-system1.67.0 libjsoncpp1 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# take application executable from build container
COPY --from=build /usr/lib/libInfluxDB.so /usr/lib
COPY --from=build /usr/bin/weather /usr/bin/

ENTRYPOINT [ "/usr/bin/weather" ]