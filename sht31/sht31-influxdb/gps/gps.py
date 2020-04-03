#!/usr/bin/python3
import sys
import pynmea2
import serial

class GPS:
   def __init__(self, pname,brate,timeout):
      self.port_name = pname
      self.baud_rate = brate 
      self.timeout = timeout
      try:	
         self.ser = serial.Serial(self.port_name,self.baud_rate, 8, 'N', 1, self.timeout)
      except:
         print('unable to open serial port')
         self.ser = None
	
   def read_gps(self):
      time = 0
      lat = 0
      lon = 0
      if self.ser is None:
         	return time, lat, lon
      else:
         while True:
            data = self.ser.readline()
            
            if sys.version_info[0] == 3:
               data = data.decode("utf-8","ignore").rstrip()
            if data[0:6] == '$GPGGA':
               msg = pynmea2.parse(data)
               time = msg.timestamp.strftime("%H:%M:%S")
               lat = msg.lat + ", " + msg.lat_dir
               lon = msg.lon + ", " + msg.lon_dir
               
               return time, lat, lon
