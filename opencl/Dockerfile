# Cross SDK
ARG CROSS_TC_IMAGE_NAME=debian-cross-toolchain-arm64-vivante
ARG DOCKER_REGISTRY=torizon
ARG CROSS_TC_IMAGE_TAG=3-bookworm

# Runtime image for a headless application
ARG IMAGE_ARCH=linux/arm64/v8
ARG DOCKER_REGISTRY=torizon
ARG BASE_NAME=debian
ARG IMAGE_TAG=3-bookworm
# Runtime image for a GUI application
# ARG BASE_NAME=wayland-base-vivante
# ARG IMAGE_TAG=3-bookworm for the SDK container and IMAGE_TAG=3 for the deploy container

# BUILD
FROM ${DOCKER_REGISTRY}/${CROSS_TC_IMAGE_NAME}:${CROSS_TC_IMAGE_TAG} AS build
ARG SDK_COMPILER_PREFIX=aarch64-linux-gnu-
WORKDIR /sample

# Install build dependencies
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	cmake \
	imx-gpu-viv-wayland-dev \
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
FROM --platform=${IMAGE_ARCH} ${DOCKER_REGISTRY}/${BASE_NAME}:$IMAGE_TAG AS deploy

# Install runtime dependencies and clinfo which is useful for debugging
RUN apt-get -y update && apt-get install -y --no-install-recommends \
        imx-gpu-viv-wayland \
	libwayland-client0 \
	clinfo \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY --from=build /sample/clpeak/build/clpeak /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/clpeak"]
