#!/bin/bash

# Functions
build_arm64 () {
    echo 'Building for arm64v8 (arm64)'
    docker build -f Dockerfile.arm64 -t yourusername/arm64v8-gpiod:latest .
}

build_armhf () {
    echo 'Building for arm32v7 (armhf)'
    docker build -f Dockerfile.armhf -t yourusername/arm32v7-gpiod:latest .
}

# Main
if [ -z "$1" ]; then
    echo 'Pass "arm32v7" or "arm64v8" as parameter!'
    exit
fi

if [ "$1" = "arm32v7" ]; then
    build_armhf
elif [ "$1" = "arm64v8" ]; then
    build_arm64
else
    echo 'Pass "arm32v7" or "arm64v8" as parameter!'
fi