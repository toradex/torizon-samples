from sht31 import sht31
from influxdb import InfluxDBClient
import gps
import socket
import time
import sys

if len(sys.argv) < 3:
    print("I2C & Serial devices as argument expected")
    sys.exit(1)

# Set the I2C device and device address
mysht31 = sht31.SHT31(sys.argv[1], 0x44)
mygps = gps.GPS(sys.argv[2],9600,1)

hostname = socket.gethostname()

client = InfluxDBClient(host='influxdb', port=8086)
client.create_database('sht31')
client.switch_database('sht31')

data = [
    {
        "measurement": "conditions",
        "tags": {
            "host": "",
        },
        "fields": {
            "cTemp": "",
            "fTemp": "",
            "humidity": "",
            "lat": "",
            "lon": "",
        }
    }
]

while True:
    # Read data from the sensor
    try:
        sensor_data = mysht31.read_sht31()
        # Process data
        cTemp, fTemp, humidity = mysht31.process_data(sensor_data)
    except:
        print("Unable to read sht31 sensor") 
        cTemp = 0;
        fTemp = 0;
        humidity = 0;

    data[0]["fields"]["cTemp"] = cTemp
    data[0]["fields"]["fTemp"] = fTemp
    data[0]["fields"]["humidity"] = humidity

    # read gps data	
    gtime, lat, lon = mygps.read_gps()
    data[0]["fields"]["lat"] = lat
    data[0]["fields"]["lon"] = lon

    data[0]["tags"]["host"] = hostname

    client.write_points(data)
    time.sleep(3)
