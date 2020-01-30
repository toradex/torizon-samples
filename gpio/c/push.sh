#!/bin/bash

# Docker hub user
DOCKER_USER=yourusername

# Function
push_docker () {
    # $1 is either arm32v7 or arm64v8
    # $2 is either armhf or arm64
    echo "Pushing for $1 ($2) / Docker hub user: $DOCKER_USER"
    docker push $DOCKER_USER/$1-c-gpiod:latest
}

# Main
if [ -z "$1" ]; then
    echo 'Pass "arm32v7" or "arm64v8" as parameter!'
    exit
fi

if [ "$1" = "arm32v7" ]; then
    push_docker arm32v7 armhf
elif [ "$1" = "arm64v8" ]; then
    push_docker arm64v8 arm64
else
    echo 'Pass "arm32v7" or "arm64v8" as parameter!'
fi