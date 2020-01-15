# GPIO example #

GPIO example using libgpiod.

Use the following command to build a container for armhf:
```
docker build -f Dockerfile.armhf -t youruser/arm32v7-gpio-test .
```
Use the following for arm64:
```
docker build -f Dockerfile.arm64 -t youruser/arm64v8-gpio-test .
```

Transfer the container to the module and use the following command:
```
docker run --rm -it --init --device /dev/gpiochip1 youruser/arm32v7-gpio-test
```

(adjust the device according to your needs)

See also https://developer.toradex.com/knowledge-base/libgpiod
