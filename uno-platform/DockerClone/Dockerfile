ARG IMAGE_ARCH=arm
# For arm64 use:
#ARG IMAGE_ARCH=arm64

# --------- BUILD
FROM mcr.microsoft.com/dotnet/sdk:5.0.102-1 AS Build

ARG IMAGE_ARCH

COPY . /build
WORKDIR /build

# build
RUN dotnet restore && \
	dotnet build && \
	dotnet build -r linux-${IMAGE_ARCH} && \
	dotnet publish -r linux-${IMAGE_ARCH}

# --------- DEPLOY
FROM --platform=linux/$IMAGE_ARCH torizonextras/dotnet-wayland-debug:latest AS Deploy

ARG IMAGE_ARCH

# install deps
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	procps \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# copy the static docker
COPY Assets/docker-$IMAGE_ARCH /usr/bin/docker
RUN chmod +x /usr/bin/docker
RUN addgroup docker && groupmod --non-unique --gid 990 docker && adduser torizon docker

# copy project
COPY --from=Build /build/bin/Debug/net5.0/linux-${IMAGE_ARCH}/publish /project

USER torizon

CMD ["./project/DockerClones"]
