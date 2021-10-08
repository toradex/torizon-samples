# current weather and forecast app for influxdb/grafana using openweathermap api

**Deprecation Notice**

The influxdb-c++ library is not being maintained anymore.
As of 2020-10-14, https://github.com/awegrzyn/influxdb-cxx shows the following warning:
"This repository has been archived by the owner. It is now read-only.".

Building this container currently fails under Debian Bullseye.

====

The following command will create a container image on your development PC:
```
# for armhf
$ docker-compose build

# for arm64
$ docker-compose build --build-arg IMAGE_ARCH=linux/arm64 --build-arg TOOLCHAIN_ARCH=aarch64 --build-arg CROSS_TC_IMAGE_ARCH=arm64
```
