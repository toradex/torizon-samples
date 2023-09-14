# ARGUMENTS --------------------------------------------------------------------
##
# Board architecture
##
ARG IMAGE_ARCH=
# For armv7 use:
#ARG IMAGE_ARCH=arm

##
# Base container version
##
ARG BASE_VERSION=3.0.8-bookworm

ARG APP_ROOT=/home/torizon

FROM --platform=linux/${IMAGE_ARCH} \
    torizon/debian:${BASE_VERSION} AS Deploy

ARG IMAGE_ARCH
ARG APP_EXECUTABLE
ARG APP_ROOT

# your regular RUN statements here
# Install required packages
RUN apt-get -q -y update && \
    apt-get -q -y install \
    python3-minimal \
    python3-pip \
    python3-venv \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    && apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create virtualenv
RUN python3 -m venv ${APP_ROOT}/.venv --system-site-packages

# Install pip packages on venv
COPY requirements-release.txt /requirements-release.txt
RUN . ${APP_ROOT}/.venv/bin/activate && \
    pip3 install --upgrade pip && pip3 install --break-system-packages -r requirements-release.txt && \
    rm requirements-release.txt

# copy the source code
COPY /src ${APP_ROOT}/src

WORKDIR ${APP_ROOT}

ENV APP_ROOT=${APP_ROOT}
# Activate and run the code
CMD . ${APP_ROOT}/.venv/bin/activate && python3 src/main.py --no-sandbox

