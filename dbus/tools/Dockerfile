FROM arm32v7/debian:buster-slim

ARG APT_PROXY

#if argument APT_PROXY is configured, it will be used to speed-up download of deb packages
RUN if [ "$APT_PROXY" != "" ]; then \
    echo "Acquire::http::Proxy \"http://$APT_PROXY:8000\";" > /etc/apt/apt.conf.d/30proxy ;\
    echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy ; \
    echo "squid-deb-proxy configured"; \
    else \
    echo "no squid-deb-proxy configured"; \
    fi

# install required packages
RUN apt-get -q -y update && apt-get -q -y --no-install-recommends install systemd dbus &&  rm -rf /var/lib/apt/lists/*

# remove proxy so container will run on any host
RUN if [ "$APT_PROXY" != "" ]; then rm /etc/apt/apt.conf.d/30proxy; fi

# remove those two statements if you want to run the tools as root
# inside the container
RUN useradd dbususer
USER dbususer
