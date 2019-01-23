# dbus tools container

This container provide dbus support and includes the busctl tool provided by systemd.  
This tool is also part of torizon core, so you may not need to run it inside a container, but this simple container can be useful if you are running your application containers with a non-root user and want to understand what is accessible for those users via dbus.  

If you want to run the tools as root inside the container, remove the user creation and activation commands inside the container (comments will guide you inside the file).  

Some useful commands you can test:

``` bash
# reboot
dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true

# power-off
dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
```