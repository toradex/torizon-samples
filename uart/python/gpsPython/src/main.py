import sys
import pynmea2
import serial

# Example using Colibri board, in UART C interface. To check the available
# interfaces for your device, please check (remember to also update the
# docker-compose.yml file):
# https://developer.toradex.com/linux-bsp/application-development/peripheral-access/uart-linux
serial_port = "/dev/colibri-uartc"

ser = serial.Serial(serial_port,9600, 8, 'N', 1, timeout=1)
while True:
     data = ser.readline()
     data = data.decode("utf-8","ignore").rstrip()
     if data[0:6] == '$GPGGA':
        msg = pynmea2.parse(data)
        print("Time = " + msg.timestamp.strftime("%H:%M:%S"))
        if msg.lat != ""  and msg.lon != "":
         print("Latitude = " + msg.lat + ", " + msg.lat_dir)
         print("Longitude = " + msg.lon + ", " + msg.lon_dir)
         print("\n")
        else:
         print("Unable to get the GPS Location on this read.")
