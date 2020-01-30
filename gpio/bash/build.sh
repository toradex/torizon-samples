#!/bin/bash

# Docker hub user
DOCKER_USER=yourusername

# Function
build_docker () {
    # $1 is either arm32v7 or arm64v8
    # $2 is either armhf or arm64
    echo "Building for $1 ($2) / Docker hub user: $DOCKER_USER"
    docker build -f Dockerfile.$2 -t $DOCKER_USER/$1-gpiod:latest .
}

# Main
if [ -z "$1" ]; then
    echo 'Pass "arm32v7" or "arm64v8" as parameter!'
    exit
fi

if [ "$1" = "arm32v7" ]; then
    build_docker arm32v7 armhf
elif [ "$1" = "arm64v8" ]; then
    build_docker arm64v8 arm64
else
    echo 'Pass "arm32v7" or "arm64v8" as parameter!'
fi