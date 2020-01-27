# Application and library to read SHT31 temperature and humidity sensor over I2C

Connect the sensor to an I2C bus on your board
```
Board            SHT31
VCC  <-------->  VCC
SCL  <-------->  SCL
SDA  <-------->  SDA
GND  <-------->  GND
```
Make sure the power supply and logic levels match between the board and the sensor.

Copy this repository to the board and build the container

For armhf:
```
docker build -t sht31 .
```

For arm64:
```
docker build --build-arg IMAGE_ARCH=arm64v8 -t sht31 .
```

Run the container using the following command:
```
docker run -it --device=/dev/i2c-0 sht31
```
The --device parameter allows the I2C bus to be accessible from within the container.
Adjust the device according to your needs. Same needs to be reflected in readSHT31.py

Sample Output:
```
Temperature in Celsius: 17.26 C
Temperature in Fahrenheit: 63.08 F
Relative Humidity: 75.88 %
.
.
```

This was tested on Apalis iMX6 Evaluation Board, i2c-0. For UART and pinout
information on this and other boards, please refer to
https://developer.toradex.com/knowledge-base/i2c-(linux)
