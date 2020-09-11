 # PWM

Sample code to interact with PWM interface exposed through sysfs

- if required, set path of pwm controller in pwm.c (/sys/class/pwm/pwmchipN)
 
- Use the following command to build an image for arm32v7 on development machine

```
docker build . -t pwm-sample
```

- To build an image for arm64v8, execute
```
docker build . --build-arg IMAGE_ARCH=arm64v8 --build-arg CROSS_TC_IMAGE_ARCH=arm64 --build-arg ARCH_ARG=linux/arm64 -t pwm-sample
```

- After image is built, it can be either uploaded to dockerhub account/some other container registry
or can be moved to target machine in portable tar archive file.

- To move it to the target machine in portable tar archive file, execute

```
docker save -o pwm-image.tar pwm-sample
```

- Now move it to target machine and load it

```
docker load -i pwm-image.tar
```

- Now image can be run and mounting of ```/sys``` is required to be able to set pwm settings

```
docker run --rm -v /sys:/sys pwm-sample
``` 

- selected pwm controller interface should be generating waveform as per period and duty cycle

