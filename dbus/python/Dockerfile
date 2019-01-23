FROM arm32v7/debian:buster-slim

ARG APT_PROXY

RUN hostname -I

#if argument APT_PROXY is configured, it will be used to speed-up download of deb packages
RUN if [ "$APT_PROXY" != "" ]; then \
    echo "Acquire::http::Proxy \"http://$APT_PROXY:8000\";" > /etc/apt/apt.conf.d/30proxy ;\
    echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy ; \
    echo "squid-deb-proxy configured"; \
    else \
    echo "no squid-deb-proxy configured"; \
    fi

# install required packages
RUN apt-get -q -y update && apt-get -q -y install python python-pip python-setuptools python-wheel pkg-config dbus libdbus-1-dev build-essential libglib2.0 libglib2.0-dev &&  rm -rf /var/lib/apt/lists/*

# remove proxy so container will run on any host
RUN if [ "$APT_PROXY" != "" ]; then rm /etc/apt/apt.conf.d/30proxy; fi

# uses pip to install python module (it needs compiler)
RUN pip install dbus-python

# adds the sample scripts
WORKDIR /root
COPY dbus-sample.py /root/dbus-sample.py
COPY list-system-services.py /root/list-system-services.py
COPY list-ip-addresses.py /root/list-ip-addresses.py

# runs python interpreter as main process
CMD python
