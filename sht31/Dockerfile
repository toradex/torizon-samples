ARG IMAGE_ARCH=arm32v7
FROM torizon/$IMAGE_ARCH-debian-base:buster

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 \
    python3-pip \
    python3-setuptools \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

COPY sht31module sht31module
RUN  cd sht31module && python3 setup.py install

COPY readSHT31.py /usr/bin

CMD python3 /usr/bin/readSHT31.py
