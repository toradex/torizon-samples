ARG IMAGE_ARCH=linux/arm
ARG IMAGE_TAG=2-bullseye
ARG BASE_NAME=debian
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip

COPY requirements.txt /requirements.txt

RUN pip install --no-cache-dir -r /requirements.txt

COPY readgps.py /usr/bin

ENTRYPOINT [ "/usr/bin/readgps.py" ]
