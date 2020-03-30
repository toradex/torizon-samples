#!/bin/sh

# check if folder for data exists and if
# it doesn't, create it
if [ ! -d /home/torizon/influxdb/data ] ; then
    mkdir -p /home/torizon/influxdb/data
fi

# create default config file if we don't have one
if [ ! -f /home/torizon/influxdb/influxdb.conf ] ; then 
    docker pull influxdb 
    docker run --rm influxdb influxd config > /home/torizon/influxdb/influxdb.conf
fi

exit 0
