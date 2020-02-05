#!/usr/bin/env sh

# this is a simple script that could be used to cleanup after you installed additional features via pip
if [ "$1" = "release" ]
then
    echo "This is a release build"
elif [ "$1" = "debug" ]
then
    echo "This is a debug build"
else
    return 1
fi
