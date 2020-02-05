## Python QML Integration 

In this sample code, UI is designed in QML and integrated with python project.
When user click on the button, humidity and temperature is read from SHT3x
kernel space driver and shown to the user on GUI.

It contains a docker file to create an image out of it.
```
docker build . -t <image name:tag>
```
Image built with this docker file is based on Qt Wayland container. Before 
running it, Weston container is needed to be run which will be the graphics 
server. Weston container is to be run in a separate terminal.
```
docker run --rm -it --privileged -v /tmp:/tmp -v /dev:/dev -v /run/udev/:/run/
udev torizon/arm32v7-debian-weston:buster weston-launch --tty=/dev/tty7 --user=
root
```

Now sample image can be run 
```
docker run --rm -it --privileged -v /dev:/dev -v /tmp:/tmp <image name:tag>
```
A window should pop up with a button and two text fields . Now temperature and 
humidity can be read by clicking on the button. 