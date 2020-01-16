FROM torizon/arm32v7-debian-base
RUN apt-get -y update && apt-get install -y \
    collectd \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
CMD ["collectd","-f"]
