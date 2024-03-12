ARG BASE_NAME=wayland-base
# Use BASE_NAME=wayland-base-vivante for i.MX8-based SoMs
# Use BASE_NAME=wayland-base-am62 for AM62-based SoMs
ARG IMAGE_ARCH=linux/arm/v7
# Use ARG IMAGE_ARCH=linux/arm64/v8 for iMX8 and AM62-based SoMs
ARG IMAGE_TAG=3
ARG DOCKER_REGISTRY=torizon

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG
 
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	libgstreamer1.0-0 \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-ugly \
	gstreamer1.0-libav \
	gstreamer1.0-tools \
	gstreamer1.0-x \
	gstreamer1.0-alsa \
	gstreamer1.0-gl \
	gstreamer1.0-gtk3 \
	gstreamer1.0-pulseaudio \
	v4l-utils \
	&& if [ "${IMAGE_ARCH}" = "linux/arm64/v8" ]; then \
		apt-get install -y --no-install-recommends \
		gstreamer1.0-qt5; fi \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["gst-launch-1.0"]

CMD ["videotestsrc", "!", "videoconvert", "!", "videoscale", "!", "waylandsink", "sync=false"]
