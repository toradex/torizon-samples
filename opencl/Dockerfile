# Cross SDK
ARG CROSS_TC_IMAGE_NAME=debian-cross-toolchain
ARG CROSS_TC_IMAGE_ARCH=arm64
ARG CROSS_TC_DOCKER_REGISTRY=torizon
ARG CROSS_TC_IMAGE_TAG=2-bullseye 


# Runtime image
ARG BASE_NAME=wayland-base-vivante

# Common to both the cross SDK and runtime image
ARG IMAGE_ARCH=linux/arm64/v8
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon

# BUILD
FROM ${CROSS_TC_DOCKER_REGISTRY}/${CROSS_TC_IMAGE_NAME}-${CROSS_TC_IMAGE_ARCH}:${CROSS_TC_IMAGE_TAG} As Build

ARG SDK_COMPILER_PREFIX=aarch64-linux-gnu-
WORKDIR /sample

# Install build dependencies
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	cmake \
	libopencl-vivante1-dev \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Fetch and build the source code
RUN git clone https://github.com/krrishnarraj/clpeak.git && \
	cd clpeak && \
	git submodule update --init --recursive --remote && \
	mkdir build && \
	cd build && \
	cmake \
		-DCMAKE_C_COMPILER=${SDK_COMPILER_PREFIX}gcc \
		-DCMAKE_CXX_COMPILER=${SDK_COMPILER_PREFIX}g++ \
		.. && \
	cmake --build .

# DEPLOY
FROM --platform=${IMAGE_ARCH} ${DOCKER_REGISTRY}/${BASE_NAME}:$IMAGE_TAG AS Deploy

# Install runtime dependencies and clinfo which is useful for debugging
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	libopencl-vivante1 \
	libclc-vivante1 \
	libgal-vivante1 \
	libvsc-vivante1 \
	libglesv2-vivante1 \
	libegl-vivante1 \
	clinfo \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY --from=Build /sample/clpeak/build/clpeak /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/clpeak"]
