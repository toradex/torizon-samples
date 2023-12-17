ARG BASE_VERSION=3

##
# Board architecture
# arm or arm64
##
ARG IMAGE_ARCH=

##
# Board GPU vendor prefix
##
ARG GPU=

##
# SoM
##
#ARG MACHINE=verdin-imx8mm
ARG MACHINE=verdin-imx8mp
#ARG MACHINE=apalis-imx8

# BUILD ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} \
    torizon/wayland-base-vivante:${BASE_VERSION} AS Base

ARG IMAGE_ARCH
ARG GPU
ARG MACHINE

ARG TORADEX_FEED_BASE_URL="https://feeds.toradex.com/debian"

RUN wget -O- ${TORADEX_FEED_BASE_URL}/toradex-debian-repo.gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/toradex-debian-repo-unstable.gpg

# Toradex unstable feed that provides NXP's downstream Gstreamer(v1.20) packages
RUN echo "\n\
Types: deb\n\
URIs: ${TORADEX_FEED_BASE_URL}/snapshots/20230328T143626Z\n\
Suites: testing\n\
Components: main non-free\n\
Signed-By: /usr/share/keyrings/toradex-debian-repo-unstable.gpg"\
    >> /etc/apt/sources.list.d/toradex.sources

# Debian snapshot that contains gstreamer1.0-plugins-ugly and
# gstreamer1.0-libav v1.20
RUN echo "\n\
Types: deb\n\
URIs: http://snapshot.debian.org/archive/debian/20220209T031931Z\n\
Suites: bookworm\n\
Components: main\n\
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg" \
    >> /etc/apt/sources.list.d/toradex.sources
RUN cat /etc/apt/sources.list.d/toradex.sources

# E: Release file for http://snapshot.debian.org/archive/debian/20230208T130000Z/dists/bookworm/InRelease is expired (invalid since 143d 2h 21min 35s). Updates for this repository will not be applied.
RUN echo "Acquire::Check-Valid-Until false;" \
    | tee -a /etc/apt/apt.conf.d/10-nocheckvalid

# Version pin packages that have a versioned dependency on GStreamer packages
COPY version-pinned-packages /etc/apt/preferences.d/version-pinned-packages

RUN apt-get update && apt-get install -y \
    imx-gpu-viv-wayland-dev \
    libg2d-viv-dev \
    linux-imx-headers-dev \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libdrm-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    pkg-config \
    build-essential \
    git \
    libtool \
    wget \
    meson \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# imx-codec
RUN wget -q https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-codec-4.7.2.bin \
    && chmod +x imx-codec-4.7.2.bin \
    && ./imx-codec-4.7.2.bin --auto-accept \
    && cd imx-codec-4.7.2 \
    && ./configure --enable-armv8 --disable-vpu --prefix=/usr \
        --libdir=/usr/lib/aarch64-linux-gnu --includedir=/usr/include \
    && make -j${nproc} \
    && make install DESTDIR=/vpusysroot \
    && rm -r /vpusysroot/usr/lib/aarch64-linux-gnu/imx-mm/video-codec \
    && mv /vpusysroot/usr/lib/aarch64-linux-gnu/imx-mm/audio-codec/lib* \
        /vpusysroot/usr/lib/aarch64-linux-gnu/ \
    && cp -r /vpusysroot/* / \
    && cd .. && rm -rf imx-codec-4.7.2.bin imx-codec-4.7.2

# imx-parser
RUN wget -q https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-parser-4.7.2.bin \
    && chmod +x imx-parser-4.7.2.bin \
    && ./imx-parser-4.7.2.bin --auto-accept \
    && cd imx-parser-4.7.2 \
    && ./configure --enable-armv8 --prefix=/usr \
        --libdir=/usr/lib/aarch64-linux-gnu --includedir=/usr/include \
    && make -j${nproc} \
    && make install DESTDIR=/vpusysroot \
    && cp -r /vpusysroot/* / \
    && cd .. && rm -rf imx-parser-4.7.2.bin imx-parser-4.7.2

# imx-vpu-hantro
RUN if [ "${MACHINE}" != "apalis-imx8" ]; then \
        wget https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-vpu-hantro-1.27.0.bin; \
        chmod +x ./imx-vpu-hantro-1.27.0.bin; \
        ./imx-vpu-hantro-1.27.0.bin --auto-accept; \
        cd imx-vpu-hantro-1.27.0; \
        if [ "${MACHINE}" = "verdin-imx8mp" ]; then \
            make -j1 PLATFORM=IMX8MP all; \
            libdir=/usr/lib/aarch64-linux-gnu/ make DEST_DIR=/vpusysroot PLATFORM=IMX8MP install; \
        elif [ "${MACHINE}" = "verdin-imx8mm" ]; then \
            make -j1 PLATFORM=IMX8MM all; \
            libdir=/usr/lib/aarch64-linux-gnu/ make DEST_DIR=/vpusysroot PLATFORM=IMX8MM install; \
        fi; \
        cp -r /vpusysroot/* /; \
        cd ..; \
        rm -rf imx-vpu-hantro-1.27.0.bin imx-vpu-hantro-1.27.0; \
    fi

# imx-vpu-hantro-vc
RUN if [ "${MACHINE}" = "verdin-imx8mp" ];then \
        wget https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-vpu-hantro-vc-1.9.0.bin; \
        chmod +x ./imx-vpu-hantro-vc-1.9.0.bin; \
        ./imx-vpu-hantro-vc-1.9.0.bin --auto-accept; \
        mkdir -p /vpusysroot/usr/include/; \
        mkdir -p /vpusysroot/usr/lib/aarch64-linux-gnu; \
        cp -r imx-vpu-hantro-vc-1.9.0/usr/include/* /vpusysroot/usr/include/; \
        cp -r imx-vpu-hantro-vc-1.9.0/usr/lib/* /vpusysroot/usr/lib/aarch64-linux-gnu; \
        cp -r /vpusysroot/* /; \
        cd ..; \
        rm -rf imx-vpu-hantro-vc-1.9.0.bin imx-vpu-hantro-vc-1.9.0; \
    fi

# imx-vpuwrap
RUN if [ "${MACHINE}" != "apalis-imx8" ]; then \
        git clone https://github.com/nxp-imx/imx-vpuwrap.git; \
        cd imx-vpuwrap; \
        git checkout MM_04.07.02_2210_L5.15.y; \
        autoreconf -Wcross --verbose --install --force; \
        ./configure --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu --disable-static; \
        make -j${nproc}; \
        make install DESTDIR=/vpusysroot; \
        cp -r /vpusysroot/* /; \
        rm -rf /vpusysroot/usr/share; \
        cd ..; \
        rm -rf imx-vpuwrap; \
    fi

# imx-gst1.0-plugin
RUN git clone https://github.com/nxp-imx/imx-gst1.0-plugin.git \
        -b MM_04.07.02_2210_L5.15.y \
    && cd imx-gst1.0-plugin \
    && meson -Dplatform=MX8 --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu \
        -Dc_args="-I/usr/include -I/usr/include/imx"  build \
    && ninja -v -j$(nproc) -C build \
    && DESTDIR=/vpusysroot ninja -v -j$(nproc) -C build install \
    && cp -r /vpusysroot/* / \
    && cd .. && rm -rf imx-gst1.0-plugin

RUN rm -rf /vpusysroot/usr/include

# DEPLOY ------------------------------------------------------------------------
FROM --platform=linux/${IMAGE_ARCH} torizon/wayland-base-vivante:${BASE_VERSION}

ARG IMAGE_ARCH
ARG GPU
ARG MACHINE

# Copy feeds and keys
COPY --from=Base /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/
COPY --from=Base /usr/share/keyrings/toradex-debian-repo-unstable.gpg \
    /usr/share/keyrings/

# E: Release file for http://snapshot.debian.org/archive/debian/20230208T130000Z/dists/bookworm/InRelease is expired (invalid since 143d 2h 21min 35s). Updates for this repository will not be applied.
RUN echo "Acquire::Check-Valid-Until false;" \
    | tee -a /etc/apt/apt.conf.d/10-nocheckvalid

# Version pin packages that have a versioned dependency on GStreamer packages
COPY version-pinned-packages  /etc/apt/preferences.d/version-pinned-packages

# Copy the downstream binaries
COPY --from=Base /vpusysroot/usr/lib/* /usr/lib/
COPY --from=Base /vpusysroot/usr/lib/aarch64-linux-gnu/gstreamer-1.0/* \
    /usr/lib/aarch64-linux-gnu/gstreamer-1.0/

# Sample script to test VPU on i.MX8
COPY vputests.sh /usr/bin/vputests

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    boxes \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-base-apps \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer1.0-0 \
    mediainfo \
    xz-utils \
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
    # __torizon_packages_prod_start__
    # __torizon_packages_prod_end__
# DO NOT REMOVE THIS LABEL: this is used for VS Code automation
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Execute vputests when starting the container
CMD [ "/usr/bin/vputests" ]
