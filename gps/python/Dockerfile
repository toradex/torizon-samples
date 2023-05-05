ARG IMAGE_ARCH=linux/arm
ARG IMAGE_TAG=3-bookworm
ARG BASE_NAME=debian
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /requirements.txt

RUN python3 -m venv /venv && /venv/bin/pip3 install --no-cache-dir -r /requirements.txt

COPY readgps.py /usr/bin

ENTRYPOINT [ "/usr/bin/readgps.py" ]
