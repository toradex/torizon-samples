#!/usr/bin/python
# import dbus module
import dbus

# require access to system bus
bus = dbus.SystemBus()

# access network manager (nm)
nm = bus.get_object("org.freedesktop.NetworkManager",
                    "/org/freedesktop/NetworkManager")

# get active connections
connpatharray = nm.Get("org.freedesktop.NetworkManager",
                       "ActiveConnections", dbus_interface=dbus.PROPERTIES_IFACE)

for connpath in connpatharray:

    conn = bus.get_object(
        "org.freedesktop.NetworkManager", connpath)

    ipv4configpath = conn.Get("org.freedesktop.NetworkManager.Connection.Active",
                              "Ip4Config", dbus_interface=dbus.PROPERTIES_IFACE)

    ipv4config = bus.get_object(
        "org.freedesktop.NetworkManager", ipv4configpath)

    addressdata = ipv4config.Get("org.freedesktop.NetworkManager.IP4Config",
                                 "AddressData", dbus_interface=dbus.PROPERTIES_IFACE)

    for address in addressdata:
        print("Address: "+address["address"])
