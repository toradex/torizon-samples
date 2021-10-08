# GPIO example #

GPIO example using libgpiod.

Use the following command to build a container:

```
docker build -t youruser/arm32v7-gpio-test .
```

Use the following for arm64:

```
docker build --build-arg IMAGE_ARCH=linux/arm64 -t youruser/arm64v8-gpio-test .
```

[Deploy the container to the module](https://developer.toradex.com/knowledge-base/deploying-container-images-to-torizoncore),
then run according to the instructions on [How to Use GPIO on TorizonCore](https://developer.toradex.com/knowledge-base/libgpiod).
