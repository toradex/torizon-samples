#!/bin/bash

# Download video samples
wget -q https://developer1.toradex.com/files/toradex-dev/uploads/media/Colibri/AddSW/Linux/ReleaseTest/media-files-1.2.tar.xz
mkdir video
tar --wildcards --strip-components=4 -xf media-files-1.2.tar.xz \
	-C ./video media-files/home/root/video/*

INFOBOX_L="boxes -d tux"
INFOBOX_S="boxes -d c"

# Set libg2d
case ${MACHINE} in
	apalis-imx8)
		update-alternatives --set libg2d.so.1 /usr/lib/aarch64-linux-gnu/libg2d-dpu.so.2.1.0
		;;
	verdin-imx8mp | verdin-imx8mm)
		update-alternatives --set libg2d.so.1 /usr/lib/aarch64-linux-gnu/libg2d-viv.so.2.1.0
		;;
	*)
		echo "Error: Unsupported machine"
		exit 1
		;;
esac

TEST="H.264 Encode"
case ${MACHINE} in
	apalis-imx8)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 videotestsrc num-buffers=300 \
			! video/x-raw, width=640, height=480 \
			! v4l2h264enc \
			! filesink location=video/test.h264
		;;
	verdin-imx8mp | verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 videotestsrc num-buffers=300 \
			! video/x-raw, width=640, height=480 \
			! vpuenc_h264 \
			! filesink location=video/test.h264
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="H.264 Decode(Self-Encoded)"
case ${MACHINE} in
	apalis-imx8)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 filesrc location=video/test.h264 \
			! h264parse \
			! v4l2h264dec \
			! imxvideoconvert_g2d \
			! waylandsink
		;;
	verdin-imx8mp | verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 filesrc location=video/test.h264 \
			! h264parse \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="H.264 Decode(Sample)"
mediainfo video/testvideo_h264.mp4 | grep "Format  "
case ${MACHINE} in
	apalis-imx8)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 filesrc location=video/testvideo_h264.mp4 \
			! qtdemux  \
			! h264parse \
			! queue \
			! v4l2h264dec \
			! imxvideoconvert_g2d \
			! waylandsink
		;;
	verdin-imx8mp | verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 filesrc location=video/testvideo_h264.mp4 \
			! qtdemux  \
			! h264parse \
			! queue \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="H.265 Encode"
case ${MACHINE} in
	verdin-imx8mp)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 videotestsrc num-buffers=300 \
			! video/x-raw, width=640, height=480 \
			! vpuenc_hevc \
			! filesink location=video/test.h265
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="H.265 Decode(Self-Encoded)"
case ${MACHINE} in
	verdin-imx8mp)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 filesrc location=video/test.h265 \
			! h265parse \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="H.265 Decode(Sample)"
case ${MACHINE} in
	apalis-imx8)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		mediainfo video/testvideo_h265.mp4 | grep "Format  "
		gst-launch-1.0 filesrc location=video/testvideo_h265.mp4 \
			! qtdemux  \
			! h265parse \
			! queue \
			! v4l2h265dec \
			! imxvideoconvert_g2d \
			! waylandsink
		;;
	verdin-imx8mp | verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		mediainfo video/testvideo_h265.mp4 | grep "Format  "
		gst-launch-1.0 filesrc location=video/testvideo_h265.mp4 \
			! qtdemux  \
			! h265parse \
			! queue \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="VP8 Encode"
case ${MACHINE} in
	verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 videotestsrc num-buffers=300 \
			! video/x-raw, width=640, height=480 \
			! vpuenc_vp8 \
			! matroskamux \
			! filesink location=video/test.mkv
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="VP8 Decode(Self-Encoded)"
case ${MACHINE} in
	verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		gst-launch-1.0 filesrc location=video/test.mkv \
			! matroskademux \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="VP8 Decode(Sample)"
case ${MACHINE} in
	apalis-imx8)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		mediainfo video/testvideo_vp8.webm | grep "Format  "
		gst-launch-1.0 filesrc location=video/testvideo_vp8.webm \
			! matroskademux \
			! v4l2vp8dec \
			! imxvideoconvert_g2d \
			! waylandsink
		;;
	verdin-imx8mp | verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		mediainfo video/testvideo_vp8.webm | grep "Format  "
		gst-launch-1.0 filesrc location=video/testvideo_vp8.webm \
			! matroskademux \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac

TEST="VP9 Decode(Sample)"
case ${MACHINE} in
	verdin-imx8mp | verdin-imx8mm)
		echo "Running ${TEST} test..." | ${INFOBOX_L}
		mediainfo video/testvideo_vp9.webm | grep "Format  "
		gst-launch-1.0 filesrc location=video/testvideo_vp9.webm \
			! matroskademux \
			! vpudec \
			! waylandsink
		;;
	*)
		echo "${MACHINE} does not support ${TEST}" | ${INFOBOX_S}
		;;
esac