 # ADC

Sample code to interact with ADC interface exposed through sysfs.

## Configure and build

If required, set name of driver and channel in `adc.c`.

Use the following command to build an image for arm32v7 on development machine:

```
docker build . -t adc-sample
```

- To build an image for arm64v8, execute:

```
docker build . --build-arg CROSS_TC_IMAGE_ARCH=arm64 --build-arg IMAGE_ARCH=linux/arm64 --build-arg GCC_PREFIX=aarch64-linux-gnu -t adc-sample
```

## Deploy

After the image is built, it can be either uploaded to Dockerhub account/some other container registry
or can be moved to target machine in portable tar archive file. Learn more on the article
[Deploying Container Images to TorizonCore](https://developer.toradex.com/knowledge-base/deploying-container-images-to-torizoncore),
especially on the section _Command-line Interface (CLI)_ that is directly applicable to this sample.
