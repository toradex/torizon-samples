# About this sample

This Docker image provides an example of how to run an application with Tensorflow Lite 2.8.0 using Python and stream it via RTSP.
The container is capable of using NPU and GPU acceleration with the tensorflow-lite-vx-delegate.

The RTSP stream can be viewed with GStreamer on another machine.

This sample is only validated for the following hardware:

- Verdin iMX8M Plus: NPU/GPU/CPU
- Apalis iMX8Q Max/Plus: GPU/CPU
- Colibri iMX8QXP: GPU/CPU
  - The Colibri iMX8QXP is not recommended to run this sample, but is suitable for lighter machine learning models.

Please refer to [Torizon Sample: Real Time Object Detection with Tensorflow Lite](https://developer.toradex.com/torizon/how-to/machine-learning/torizon-sample-real-time-tensorflow-lite) to learn more about this sample.

## To build the image, execute

```bash
docker build -t <your-dockerhub-username>/tflite-rtsp .
```
## To run the demo, execute

```bash
docker run -it --rm -p 8554:8554 \
  -v /dev:/dev \
  -v /tmp:/tmp \
  -v /run/udev/:/run/udev/ \
  --device-cgroup-rule='c 4:* rmw' \
  --device-cgroup-rule='c 13:* rmw' \
  --device-cgroup-rule='c 199:* rmw' \
  --device-cgroup-rule='c 226:* rmw' \
  --device-cgroup-rule='c 81:* rmw' \
  -e CAPTURE_DEVICE=/dev/video0 \
  -e USE_HW_ACCELERATED_INFERENCE=1 \
  -e USE_GPU_INFERENCE=1 \
  -e ACCEPT_FSL_EULA=1 \
  --name tflite-rtsp <image-tag>
```

## To view the application output, execute

```bash
gst-launch-1.0 rtspsrc location=rtsp://<board ip address>:8554/inference ! decodebin ! xvimagesink sync=false
```
