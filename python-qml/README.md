    ## Python QML Integration 

In this sample code, UI is designed in QML and integrated with python project
using PySide2. When user click on the button, humidity and temperature is read 
from SHT3x kernel space driver (assuming it is already set with address 0x44) 
and shown to the user on GUI.

It contains a docker file to create an image out of it that is compatible
with armhf architecture.  For building the image:
```
docker build --pull . -t <image name:tag>
```
Image built with this docker file is based on Qt Wayland container. Before 
running it, Weston container is needed to be run in the device which will be the graphics 
server. Weston container is to be run in a separate terminal.
```
docker run -d --rm --name=weston-container --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
    --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 199:* rmw' --device-cgroup-rule='c 226:* rmw' \
    torizon/weston:$CT_TAG_WESTON --developer weston-launch \
    --tty=/dev/tty7 --user=torizon
```

Now the sample image can be run 
```
docker run --rm --privileged -v /dev:/dev -v /tmp:/tmp <image name:tag>
```
A window should pop up with a button and two text fields. Now temperature and 
humidity can be read by clicking on the button. 
