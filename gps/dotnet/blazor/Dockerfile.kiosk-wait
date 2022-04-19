ARG IMAGE_ARCH=linux/arm
# For Apalis iMX8 use IMAGE_ARCH=linux/arm64

FROM --platform=$IMAGE_ARCH torizon/chromium:2

# Switch to root user to install additional packages
USER root

RUN sudo apt-get update \
    && apt-get install -y --no-install-recommends \
    wait-for-it \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

USER torizon
