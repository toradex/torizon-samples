FROM torizon/wayland-base-vivante:2

RUN apt-get -y update && apt-get install -y \
	git \
	build-essential \
	cmake \
	wget \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN git config --global user.email "you@example.com" && \
	git config --global user.name "Your Name"

WORKDIR /home/torizon

RUN apt-get -y update && apt-get install -y \
	libopencl-vivante1 \
	libopencl-vivante1-dev \
	libclc-vivante1 \
	libgal-vivante1 \
	libvsc-vivante1 \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/krrishnarraj/clpeak.git && \
	cd clpeak && \
	git submodule update --init --recursive --remote

RUN mkdir -p clpeak/buid &&\
	cd clpeak/buid && \
	cmake .. && \
	cmake --build .

ENTRYPOINT clpeak/buid/clpeak
