import smbus2
import time

# Define a class
class SHT31:
    def __init__(self, bus, addr):
        self.bus = bus
        self.addr = addr

    # Read data from the sensor
    def read_sht31(self):
        bus = smbus2.SMBus(self.bus)

        # SHT31 address, measurement command, repeatability
        # Address, usually 0x44(68), is configurable to 0x45(69) by pulling up ADDR pin
        # Single shot mode measurement command with clock stretching enabled 0x2C(44)
        # High repeatability measurement 0x06(06)
        bus.write_i2c_block_data(self.addr, 0x2C, [0x06])

        time.sleep(0.5)

        # SHT31 address, register address, number of bytes to read
        # Read from 0x00(00), this is ignored by the sensor, still need to specify for SMBus
        # Read 6 bytes: Temp MSB, Temp LSB, Temp CRC, Humididty MSB, Humidity LSB, Humidity CRC
        data = bus.read_i2c_block_data(self.addr, 0x00, 6)

        return data

    # Process data received from the sensor
    def process_data(self, data):
        temp = data[0] * 256 + data[1]
        cTemp = -45 + (175 * temp / 65535.0)
        fTemp = -49 + (315 * temp / 65535.0)
        humidity = 100 * (data[3] * 256 + data[4]) / 65535.0

        return cTemp, fTemp, humidity
