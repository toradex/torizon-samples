ARG IMAGE_ARCH=arm32v7
FROM torizon/$IMAGE_ARCH-debian-qt5-wayland:buster

ARG APPNAME=show_readings.py

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    qml-module-qtquick2 \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-dialogs \
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
