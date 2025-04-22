ARG CROSS_SDK_BASE_TAG=4
ARG BASE_VERSION=4
##
# Board architecture
##
ARG IMAGE_ARCH=

##
# Directory of the application inside container
##
ARG APP_ROOT=


# BUILD ------------------------------------------------------------------------
FROM torizon/cross-toolchain-${IMAGE_ARCH}:${CROSS_SDK_BASE_TAG} AS build

ARG APP_ROOT
ARG IMAGE_ARCH

# __deps__
RUN apt-get -q -y update && \
    apt-get -q -y install \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_build_start__
    # __torizon_packages_build_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
# __deps__

COPY . ${APP_ROOT}
WORKDIR ${APP_ROOT}

# Remove the code from the debug builds, inside this container, to build the
# release version from a clean build
RUN rm -rf ${APP_ROOT}/build-${IMAGE_ARCH}

# Compile the application
RUN if [ "$IMAGE_ARCH" = "arm64" ] ; then \
        make ARCH=${IMAGE_ARCH} CC=aarch64-linux-gnu-gcc ; \
    elif [ "$IMAGE_ARCH" = "armhf" ] ; then \
        make ARCH=${IMAGE_ARCH} CC=arm-linux-gnueabihf-gcc ; \
    elif [ "$IMAGE_ARCH" = "amd64" ] ; then \
        make ARCH=${IMAGE_ARCH} CC=x86_64-linux-gnu-gcc ; \
    fi

# BUILD ------------------------------------------------------------------------


# DEPLOY -----------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/debian:${BASE_VERSION} AS deploy

ARG IMAGE_ARCH
ARG APP_ROOT

RUN apt-get -y update && apt-get install -y --no-install-recommends \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*


# Copy the application compiled in the build step to the $APP_ROOT directory
# path inside the container, where $APP_ROOT is the torizon_app_root
# configuration defined in settings.json
COPY --from=build ${APP_ROOT}/build-${IMAGE_ARCH}/bin ${APP_ROOT}

# "cd" (enter) into the APP_ROOT directory
WORKDIR ${APP_ROOT}

# Command executed in runtime when the container starts
CMD ["./adcC"]

# DEPLOY -----------------------------------------------------------------------
