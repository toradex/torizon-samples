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
docker-compose up
```

Docker compose will start a browser in kiosk mode and point it to the web page
served by the flaskapp. The page contains two tabs; one for realtime chart and
other for historical data chart.

This was tested on Apalis iMX6 Evaluation Board, i2c-0. For UART and pinout
information on this and other boards, please refer to
https://developer.toradex.com/knowledge-base/i2c-(linux)

