# Choose IMAGE_ARCH either "arm32v7" or "arm64v8"
ARG IMAGE_ARCH=arm32v7
# Either leave MODULES_VIVANTE empty or set it to "-vivante"
# which is the suffix for both the Docker image as well as Debian packages
ARG MODULES_VIVANTE
FROM torizon/$IMAGE_ARCH-debian-qt5-wayland$MODULES_VIVANTE:buster

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
