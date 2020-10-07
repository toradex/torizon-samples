# Python/Flask web app to show data from SHT31 I2C temp/humidity sensor

Connect the sensor to an I2C bus on your board
```
Board            SHT31
VCC  <-------->  VCC
SCL  <-------->  SCL
SDA  <-------->  SDA
GND  <-------->  GND
```
Make sure the power supply and logic levels match between the board and the sensor.

Copy this repository to the board and launch the services

For armhf:
```
docker-compose build --pull
docker-compose up
```

For arm64:
First make the changes described in following files for arm64:
```
docker-compose.yml
flaskapp/Dockerfile
sht31-influxdb/Dockerfile
kiosk/Dockerfile
```

and do
```
docker-compose build --pull --build-arg IMAGE_ARCH=linux/arm64
docker-compose up
```

Docker compose will start a browser in kiosk mode and point it to the web page
served by the flaskapp. The page contains two tabs; one for realtime chart and
other for historical data chart.

This was tested on Apalis iMX6 Evaluation Board, using Apalis I2C1
(/dev/apalis-i2c1). Adjust docker-compose.yml to use the I2C bus for a
particular module/familiy.


