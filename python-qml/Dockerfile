ARG IMAGE_ARCH=arm32v7
FROM torizon/$IMAGE_ARCH-debian-qt5-wayland:buster

ARG APPNAME=show_readings.py

RUN apt-get update && apt-get install -y --no-install-recommends python3 && rm -rf /var/lib/apt/lists/*

COPY setup.sh /setup.sh

WORKDIR /
RUN /setup.sh debug

ENV ENVAPPNAME ${APPNAME}

COPY ./app /app

WORKDIR /app

CMD python3 $ENVAPPNAME
