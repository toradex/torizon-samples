#!/usr/bin/python3
import sys
import pynmea2
import serial
ser = serial.Serial("/dev/ttymxc1",9600, 8, 'N', 1, timeout=1)
while True:
     data = ser.readline()
     if sys.version_info[0] == 3:
        data = data.decode("utf-8","ignore").rstrip()
     if data[0:6] == '$GPGGA':
        msg = pynmea2.parse(data)
        print("Time = " + msg.timestamp.strftime("%H:%M:%S"))
        print("Latitude = " + msg.lat + ", " + msg.lat_dir)
        print("Longitude = " + msg.lon + ", " + msg.lon_dir)
        print("\n")
