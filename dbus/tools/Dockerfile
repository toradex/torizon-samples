ARG BASE_NAME=debian
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2-bullseye
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

# install required packages
RUN apt-get -q -y update && apt-get -q -y --no-install-recommends install systemd dbus &&  rm -rf /var/lib/apt/lists/*

# run the tools as a dedicated user
# remove if you want to run as root inside the container
RUN useradd -m dbususer
USER dbususer
WORKDIR /home/dbususer

CMD ["/bin/bash", "-l"]
