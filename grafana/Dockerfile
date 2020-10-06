ARG IMAGE_TAG=2-bullseye
FROM --platform=linux/arm torizon/debian:$IMAGE_TAG
RUN apt-get -y update && apt-get install -y \
    libmnl0 \
    collectd \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
CMD ["collectd","-f"]
