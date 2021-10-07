FROM --platform=linux/arm torizon/debian:2-bullseye

# install required packages
RUN apt-get -q -y update && apt-get -q -y --no-install-recommends install systemd dbus &&  rm -rf /var/lib/apt/lists/*

# run the tools as a dedicated user
# remove if you want to run as root inside the container
RUN useradd -m dbususer
USER dbususer
WORKDIR /home/dbususer

CMD /bin/bash -l
