from sht31 import sht31

# Set the bus number and device address
mysht31 = sht31.SHT31(0, 0x44)

while True:
    # Read data from the sensor
    data = mysht31.read_sht31()

    # Process data
    cTemp, fTemp, humidity = mysht31.process_data(data)

    # Print to stdout
    print("Temperature in Celsius: %.2f C" %cTemp)
    print("Temperature in Fahrenheit: %.2f F" %fTemp)
    print("Relative Humidity: %.2f %%\n" %humidity)
