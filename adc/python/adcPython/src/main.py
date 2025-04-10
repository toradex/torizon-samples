#!/usr/bin/env python3
import time
import os
import sys

# Example using Verdin board, in UART Python interface. To check the available
# interfaces for your device, please check (remember to also update the
# docker-compose.yml file):
# https://developer.toradex.com/linux-bsp/application-development/peripheral-access/uart-linux

adc_device_path = "/dev/verdin-adc1"  

if not os.path.exists(adc_device_path):
    print(f"Error: ADC device {adc_device_path} not found. Check if it is mapped correctly on docker-compose.yml.")
    sys.exit(1)

print(f"Reading ADC values from {adc_device_path}... Press Ctrl+C to stop.")
try:
    while True:
        try:
            with open(adc_device_path, "r") as adc_file:
                adc_value_str = adc_file.read().strip()
                adc_value_mv = int(adc_value_str)
                adc_value_v = adc_value_mv / 1000
            print(f"ADC Reading: {adc_value_v:.3f} V")
        except Exception as e:
            print(f"Error reading ADC device: {e}")
        time.sleep(1)
except KeyboardInterrupt:
    print("\nExiting ADC reader.")
