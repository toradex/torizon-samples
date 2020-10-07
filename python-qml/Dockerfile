ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG IMAGE_NAME=qt5-wayland
# For arm64 with Vivante use:
# ARG IMAGE_NAME=qt5-wayland-vivante
FROM --platform=$IMAGE_ARCH torizon/$IMAGE_NAME:2

ARG APPNAME=show_readings.py

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    qml-module-qtquick2$MODULES_VIVANTE \
    qml-module-qtquick-controls$MODULES_VIVANTE \
    qml-module-qtquick-controls2$MODULES_VIVANTE \
    qml-module-qtquick-dialogs$MODULES_VIVANTE \
    python3-pyside2.qtcore \
    python3-pyside2.qtquick \
    python3-pyside2.qtwidgets \
    python3-pyside2.qtgui \
    python3-pyside2.qtqml \
    python3-pyside2.qtnetwork \
    && rm -rf /var/lib/apt/lists/*
 
WORKDIR /

ENV ENVAPPNAME ${APPNAME}

COPY ./app /app

WORKDIR /app

CMD python3 $ENVAPPNAME
