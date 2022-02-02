# About this sample

This Docker image provides an example of how to quickly build an application with Tensorflow Lite using Python for distinct NXP's i.MX SoCs.


- To build an image for arm64v8, execute:
```
docker build -t <your-dockerhub-username>/tflite_example .
```

- Use the following command to build an image for arm32v7 on development machine:
```
docker build --build-arg ARCH_ARG=linux/arm --build-arg PKG_ARCH=armv7l -t <your-dockerhub-username>/tflite_example .
```

Please refer to [Torizon Sample: Image Classification with Tensorflow Lite](https://developer.toradex.com/knowledge-base/torizon-sample-tensorflow-lite) to know more about it.
