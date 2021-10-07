FROM --platform=linux/arm torizon/debian:2-bullseye

# install required packages
RUN apt-get -q -y update && apt-get -q -y install \
    python python3-pip python-setuptools python3-wheel \
    pkg-config \
    dbus libdbus-1-dev \
    build-essential \
    libglib2.0 libglib2.0-dev && \
    rm -rf /var/lib/apt/lists/*

# uses pip to install python module (it needs compiler)
RUN pip install dbus-python

# adds the sample scripts
WORKDIR /root
COPY dbus-sample.py /root/dbus-sample.py
COPY list-system-services.py /root/list-system-services.py
COPY list-ip-addresses.py /root/list-ip-addresses.py

# runs python interpreter as main process
CMD python3
