ARG BASE_NAME=qt5-wayland
# For arm64 without Vivante use:
# ARG BASE_NAME=qt5-wayland
# arm64 with Vivante(ARG BASE_NAME=qt5-wayland-vivante) is currently not
# supported as python3-pyside2.qtgui is not co-installable with libqt5qui5-gles
# See: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=974101
ARG IMAGE_ARCH=linux/arm/v7
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG IMAGE_TAG=2
ARG DOCKER_REGISTRY=torizon

ARG APPNAME=show_readings.py

# Build the sample python-qml container.
FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

ARG APPNAME

# Remove libqt5gui5-gles in favor of libqt5gui5. On armhf both libqt5gui5 and
# libqt5gui5-gles are built with -opengl es2, so technically there is no change
# for armhf
RUN apt-get remove libqt5opengl5 --allow-change-held-packages \
    && apt-get remove libqt5gui5-gles

# Install libqt5gui5 and also reinstall libqt5opengl5 and the packages dependent
# on libqt5gui5-gles that got removed as a result of removing libqt5gui5-gles
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libqt5opengl5 libqt5gui5 libqt5printsupport5 libqt5quick5 libqt5quickparticles5 \
    libqt5quickshapes5 libqt5quicktest5 libqt5quickwidgets5 libqt5waylandclient5 \
    libqt5waylandcompositor5 libqt5widgets5 qml-module-qtquick-layouts \
    qml-module-qtquick-particles2 qml-module-qtquick-shapes \
    qml-module-qtquick-window2 qml-module-qtquick2 \
    qml-module-qttest qtwayland5 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install further dependencies for the sample application.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    python3 \
    qml-module-qtquick2 \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls \
    qml-module-qtquick-dialogs \
    python3-pyside2.qtcore \
    python3-pyside2.qtquick \
    python3-pyside2.qtwidgets \
    python3-pyside2.qtqml \
    python3-pyside2.qtnetwork \
    python3-pyside2.qtgui \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
 
WORKDIR /

ENV ENVAPPNAME ${APPNAME}

COPY ./app /app

WORKDIR /app

CMD ["sh", "-c", "python3 $ENVAPPNAME"]
