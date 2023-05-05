ARG BASE_NAME=debian
ARG IMAGE_TAG=3-bookworm
ARG DOCKER_REGISTRY=torizon

# Select the image architecture
# For arm64 use:
ARG IMAGE_ARCH=linux/arm64/v8
# For arm32 use:
#ARG IMAGE_ARCH=linux/arm/v7

FROM --platform=$IMAGE_ARCH $DOCKER_REGISTRY/$BASE_NAME:$IMAGE_TAG
WORKDIR /home/torizon

# Install node and npm
RUN apt-get update \
 && apt-get install -y --no-install-recommends nodejs npm \
 && apt-get clean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

# Copy files
COPY app.js package.json ./

# Configure npm
ENV NPM_CONFIG_LOGLEVEL info

# Run npm using the configuration from package.json
RUN npm install
EXPOSE 3000

# Run script
ENTRYPOINT ["node"]
CMD ["app.js"]
