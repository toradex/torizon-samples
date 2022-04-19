ARG BASE_NAME=chromium
ARG IMAGE_ARCH=linux/arm
# For Apalis iMX8 use IMAGE_ARCH=linux/arm64
ARG IMAGE_TAG=2
ARG KIOSK_DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $KIOSK_DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

# Switch to root user to install additional packages
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wait-for-it \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

USER torizon
