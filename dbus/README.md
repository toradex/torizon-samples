# dbus samples

Those samples show how to use dbus from a container.  
Dbus can be used to control some aspects of the host system and change its configuration. For example it's possible to get the host network IP (even if the container is using default bridge networking), change the network configuration or detect when a network device changes it's state.

When you run containers that need to access dbus you need to mount /var/run/dbus:

```bash
docker run -v /var/run/dbus:/var/run/dbus <image name>
``` 

- **tools**  
  Allows you to build a container that can be used to run busctl and dbus-send as non-root user inside a container, can be useful to debug permission issues.

- **python**  
  Shows how to use python dbus library to perform some dbus operations from inside a container.
