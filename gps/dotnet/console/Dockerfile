ARG IMAGE_ARCH=arm64v8
# --------- BUILD
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build

COPY . /project
WORKDIR /project

# build
RUN dotnet restore && \
	dotnet build && \
	dotnet build -r linux-arm64 && \
	dotnet publish -r linux-arm64

# --------- DEPLOY
FROM torizon/$IMAGE_ARCH-debian-dotnet AS deploy

# copy project
COPY --from=build /project/bin/Debug/netcoreapp3.1/linux-arm64/publish /project

# set here the serial device that will be used on
ENV GPS_SERIAL_PORT="/dev/apalis-uart4"

WORKDIR /project/

CMD ["./gps"]
