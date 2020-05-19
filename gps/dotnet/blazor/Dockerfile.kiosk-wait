ARG IMAGE_ARCH=arm32v7
# For Apalis iMX8 use IMAGE_ARCH=arm64v8

FROM torizon/$IMAGE_ARCH-debian-kiosk-mode-browser:buster

# Switch to root user to install additional packages
USER root

RUN sudo apt-get update \
    && apt-get install -y --no-install-recommends \
    wait-for-it \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

USER torizon
