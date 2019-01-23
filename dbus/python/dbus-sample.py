#!/usr/bin/python
# import dbus module
import dbus

# require access to system bus
bus = dbus.SystemBus()

# access systemd manager using its path
proxy = bus.get_object('org.freedesktop.systemd1', '/org/freedesktop/systemd1')

# access standard dbus interface to read/write properties
props = dbus.Interface(proxy, dbus.PROPERTIES_IFACE)

# print version
print(str(props.GetAll("org.freedesktop.systemd1.Manager")["Version"]))

# access the Manager interface
manager = dbus.Interface(proxy, "org.freedesktop.systemd1.Manager")

# invoke reboot method
manager.Reboot()
