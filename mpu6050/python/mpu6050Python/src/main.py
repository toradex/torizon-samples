# Details about MPU6050 registers are available at https://invensense.tdk.com/wp-content/uploads/2015/02/MPU-6000-Register-Map1.pdf
import smbus2
import time

# The bus to which the MPU6050 is connected
bus = smbus2.SMBus('/dev/verdin-i2c1')

# Sensor address
device_address = 0x68

# MPU6050 power management register
PWR_MGMT_1 = 0x6B

# MPU6050 sample rate register
SMPRT_DIV = 0x19

# MPU6050 configuration registers
CONFIG = 0x1A
GYRO_CONFIG = 0x1B
ACELL_CONFIG = 0x1C

# MPU6050 data registers
ACCEL_XOUT_H = 0x3B
ACCEL_YOUT_H = 0x3D
ACCEL_ZOUT_H = 0x3F
GYRO_XOUT_H = 0x43
GYRO_YOUT_H = 0x45
GYRO_ZOUT_H = 0x47

# Initial configuration for the MPU6050
# Select the internal oscillator (8MHz) as clock source
bus.write_byte_data(device_address, PWR_MGMT_1, 0x00)
# Configure the sample rate as 1kHz
bus.write_byte_data(device_address, SMPRT_DIV, 0x07)
# Disable DLPF and FSYNC
bus.write_byte_data(device_address, CONFIG, 0x06)
# Set the full-scale range of the gyroscope output as +/- 2000 deg/s
bus.write_byte_data(device_address, GYRO_CONFIG, 0x18)
# Set the full-scale range of the accelerometer output as +/- 16g
bus.write_byte_data(device_address, ACELL_CONFIG, 0x18)

def read_mpu6050(register_addres):
	# Accelerometer and gyroscope measurements values are 16-bit
	high = bus.read_byte_data(device_address, register_addres)
	low = bus.read_byte_data(device_address, register_addres+1)

	# Convert the 8-bit values into a 16-bit value
	value = ((high << 8) | low)
	
	# Convert to 16-bit 2’s complement value
	if value & (1 << 15):
		value = value - (1 << 16)

	return value

# Continously read sensor measurements
while True:
	# Read Accelerometer raw values
	accel_x_raw = read_mpu6050(ACCEL_XOUT_H)
	accel_y_raw = read_mpu6050(ACCEL_YOUT_H)
	accel_z_raw = read_mpu6050(ACCEL_ZOUT_H)

	# Read Gyroscope raw values
	gyro_x_raw = read_mpu6050(GYRO_XOUT_H)
	gyro_y_raw = read_mpu6050(GYRO_YOUT_H)
	gyro_z_raw = read_mpu6050(GYRO_ZOUT_H)

	# Convert values based on the chosen full-scale ranges
	accel_x = accel_x_raw/2048.0
	accel_y = accel_y_raw/2048.0
	accel_z = accel_z_raw/2048.0
	
	gyro_x = gyro_x_raw/16.4
	gyro_y = gyro_y_raw/16.4
	gyro_z = gyro_z_raw/16.4
	
	print("Accel X = {:.2f}°/s    Accel Y = {:.2f}°/s    Accel Z = {:.2f}°/s  |  Gyro X = {:.2f}g    Gyro Y ={:.2f}g    Gyro Z = {:.2f}g".format(accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z))

	time.sleep(0.5)