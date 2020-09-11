# Read GPS(connected to UART) from within a container

GPS/UART example using pyserial and pynmea

Connect the UART of a GPS Module to an available UART on your board.
```
Board            GPS
VCC  <-------->  VCC
RX   <-------->  TX
TX   <-------->  RX
GND  <-------->  GND
```
Make sure the power supply and logic levels match between the board and gps.

Copy this repository to the board and build the container

For armhf:
```
docker build -t gps .
```

For arm64:
```
docker build --build-arg IMAGE_ARCH=linux/arm64 -t gps .
```

Run the container using the following command:
```
# docker run -it --rm --device=/dev/ttymxc1 readgps
```
The --device parameter allows the UART to be accessible from within the container.
Adjust the device according to your needs. Same needs to be reflected in readgps.py

Sample Output:
```
Time = 07:53:31
Latitude = 3340.18707, N
Longitude = 07259.43225, E
.
.
```

This was tested on Apalis iMX6 Evaluation Board, UART2. For UART and pinout
information on other boards, please refer to
https://developer.toradex.com/knowledge-base/uart-(linux)
