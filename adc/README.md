 # ADC

Sample code to interact with ADC interface exposed through sysfs

- if required, set name of driver and channel in ```adc.c```
 
- Use the following command to build an image for arm32v7 on development machine

```
docker build . -t adc-sample
```

- To build an image for arm64v8, execute
```
docker build . --build-arg IMAGE_ARCH=arm64v8 --build-arg CROSS_TC_IMAGE_ARCH=arm64 --build-arg ARCH_ARG=linux/arm64 --build-arg IMAGE_TAG=1-buster -t adc-sample
```

- After image is built, it can be either uploaded to dockerhub account/some other container registry
or can be moved to target machine in portable tar archive file.

- To move it to the target machine in portable tar archive file, execute

```
docker save -o adc-image.tar adc-sample
```

- Now move it to target machine and load it

```
docker load -i adc-image.tar
```

- Now image can be run by executing

```
docker run --rm adc-sample
``` 

- Raw value of input channel and Voltage will be shown on the terminal.