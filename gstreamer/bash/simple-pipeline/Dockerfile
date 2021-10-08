ARG BASE_NAME=wayland-base
# Use BASE_NAME=wayland-base-vivante for i.MX 8 SoMs
ARG IMAGE_ARCH=linux/arm/v7
ARG IMAGE_TAG=2

FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME:$IMAGE_TAG
ARG IMAGE_ARCH
 
RUN apt-get -y update && apt-get install -y \
	libgstreamer1.0-0 \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-ugly \
	gstreamer1.0-libav \
	gstreamer1.0-doc \
	gstreamer1.0-tools \
	gstreamer1.0-x \
	gstreamer1.0-alsa \
	gstreamer1.0-gl \
	gstreamer1.0-gtk3 \
	gstreamer1.0-pulseaudio \
	&& if [ "${IMAGE_ARCH}" = "linux/arm64/v8" ]; then \
		apt-get install -y \
		gstreamer1.0-qt5; fi \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
	
ENTRYPOINT ["gst-launch-1.0"] 

CMD ["-v", "videotestsrc",  "!",  "videoconvert",  "!",  "videoscale",  "!",  "waylandsink",  "sync=false"]
