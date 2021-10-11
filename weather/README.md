# Multi-container C++ app with a DB and a chart plot tool

This sample showcases how to use multiple containers on Torizon, being one of
them a C++ based app with an external library. The openweathermap API was
selected for the C++ sample because it may be a good template for you to
use your own APIs.

Using InfluxDB and Grafana as database and visualization containers are meant
to showcase that you can leverage the Docker ecosystem by using existing
containers.

====

The following command will create a container image on your development PC:
```
# for armhf
$ docker-compose build

# for arm64
$ docker-compose build --build-arg IMAGE_ARCH=linux/arm64 --build-arg TOOLCHAIN_ARCH=aarch64 --build-arg CROSS_TC_IMAGE_ARCH=arm64
```
