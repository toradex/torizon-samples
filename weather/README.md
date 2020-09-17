# current weather and forecast app for influxdb/grafana using openweathermap api

The following command will create a container image on your development PC:
```
# for armhf
$ docker-compose build

# for arm64
$ docker-compose build --build-arg IMAGE_ARCH=linux/arm64 --build-arg TOOLCHAIN_ARCH=aarch64 --build-arg PKG_ARCH=arm64
```