ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    gpiod \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Allow the user torizon use GPIOs
RUN usermod -a -G gpio torizon

# Add sample bash scripts for convenience
COPY ./*.sh /usr/local/bin/

CMD [ "bash" ]
