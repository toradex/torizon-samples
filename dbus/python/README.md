# dbus sample using python

This sample will show how to interface with dbus from a python script.
The dbus interface provided by Torizon core is limited to org.freedesktop.systemd1 service, documented [here](https://www.freedesktop.org/wiki/Software/systemd/dbus/).  

To run this sample you first need to build a container.  
You must have docker installed on your development machine, you'll find the docker file and a sample script in this folder.

The sample will show how to display some properties about the current device and how to reboot it.  

All the python code shown is inside file dbus-sample.py in this folder.  

1. First you have to build the container from command line:

    ```bash
    docker build --rm -t dbus-sample-py .
    ```
1. Then you can deploy it to your torizon device using ssh (address is the hostname or ip address of your device, user is the username you plan to use to run container, default is torizon):

    ```bash
    docker save dbus-sample-py | ssh <user>@<address> docker load
    ```

1. After you have imported your container you have to ssh into the device and run it

    ```bash
    docker run -it --rm -v /var/run/dbus:/var/run/dbus -v /usr/share/dbus-1/services:/usr/share/dbus-1/services dbus-sample-py
    ```

    To be able to access dbus interface from inside the container we need to map the folder where dbus creates its sockets (/var/run/dbus) and the one where it keeps services descriptions (used by python module to "remap" service methods and properties to python objects).  
    If everything is correct, this will start the python interpreter

1. First you need to import dbus module

    ```python
    import dbus
    ```

1. Then you need to access the system dbus and obtain a proxy for the manager object, given its path:  

    ```python
    bus = dbus.SystemBus()
    proxy = bus.get_object('org.freedesktop.systemd1', '/org/freedesktop/systemd1')
    ```

1. To access object properties we need to use the standard org.freedesktop.DBus.Properties interface:

    ```python
    props = dbus.Interface(proxy, "org.freedesktop.DBus.Properties")
    print(str(props.GetAll("org.freedesktop.systemd1.Manager")["Version"]))
    ```

1. To access the Manager interface and its methods you need to use dbus.Interface again:  

    ```python
    manager = dbus.Interface(proxy, "org.freedesktop.systemd1.Manager")
    manager.Reboot()
    ```

1. The device will reboot, as expected  

Please notice that this may not be the best way to reboot your device, because it will skip regular shutdown steps.  

# Other samples #

1. The list-system-services.py sample (provided by Collabora) can be used to list all available services (only system dbus is currently exposed in torizon).
To run it from python interpreter you can type:

    ```python
    execfile("list-system-services.py")
    ```

1. list-ip-addresses.py shows how to interface with org.freedesktop.NetworkManager to list valid IPs for the device (this is the host device, not the container itself)

    ```python
    execfile("list-device-addresses.py")
    ```
