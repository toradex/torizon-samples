ARG CROSS_SDK_BASE_TAG=3.0.9-bookworm
ARG BASE_VERSION=3.0.8-bookworm
##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

##
# Application Name
##
ARG APP_EXECUTABLE=spiC


# BUILD ------------------------------------------------------------------------
FROM torizon/debian-cross-toolchain-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} As Build

ARG IMAGE_ARCH
ARG COMPILER_ARCH
ENV IMAGE_ARCH ${IMAGE_ARCH}

RUN usermod -a -G spidev torizon

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_dev_start__
    # __torizon_packages_dev_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

COPY . /app
WORKDIR /app

RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        make ARCH=. CC=aarch64-linux-gnu-g++ ; \
    elif [ "$IMAGE_ARCH" = "arm" ] ; then \
        make ARCH=. CC=arm-linux-gnueabihf-g++ ; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        make ARCH=. CC=x86_64-linux-gnu-g++ ; \
    fi

# BUILD ------------------------------------------------------------------------


# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ENV APP_EXECUTABLE ${APP_EXECUTABLE}

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the build
COPY --from=Build /app/bin /app

# ADD YOUR ARGUMENTS HERE
CMD [ "./app/spiC" ]

# DEPLOY ------------------------------------------------------------------------
