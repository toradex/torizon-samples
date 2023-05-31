# GPIO example #

GPIO example using libgpiod.

Use the following command to build a container for arm32v7:

```
docker build -t <yourDockerHubUsername>/arm32v7-c-gpiod .
```

Use the following command to build a container for arm64v8:

```
docker build --build-arg CROSS_TC_IMAGE_ARCH=arm64 --build-arg GCC_PREFIX=aarch64-linux-gnu --build-arg IMAGE_ARCH=linux/arm64 -t <yourDockerHubUsername>/arm64v8-c-gpiod .
```

[Deploy the container to the module](https://developer.toradex.com/knowledge-base/deploying-container-images-to-torizoncore),
then run according to the instructions on [How to Use GPIO on TorizonCore](https://developer.toradex.com/knowledge-base/libgpiod).
