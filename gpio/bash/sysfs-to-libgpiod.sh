#!/bin/bash

echo "This examples uses Toradex Colibri iMX8X"
echo "It uses SODIMM 25 and 27 as examples. They correspond to GPIO chip 0 / \
pin 29 and 30"
echo "The equivalent sysfs numbers are 509 and 510 - they come from \
https://developer.toradex.com/knowledge-base/gpio-alphanumeric-to-gpio-numeric-assignment#iMX_8_iMX8X"

# SODIMM 25
# LSIO.GPIO00.IO29
# sysfs number - 509

# SODIMM 27
# LSIO.GPIO00.IO30
# sysfs number - 510


# Read GPIO - sysfs
# echo 509 > /sys/class/gpio/export
# echo "in" > /sys/class/gpio/gpio509/direction
# cat /sys/class/gpio/gpio509/value

# Read GPIO - libgpiod
gpioget 0 29

# Set GPIO - sysfs
# echo 510 > /sys/class/gpio/export
# echo "out" > /sys/class/gpio/gpio510/direction
# echo 1 > /sys/class/gpio/gpio510/value
# or
# echo high > /sys/class/gpio/gpio510/direction

# Set GPIO - libgpiod
gpioset 0 29=1

# Clear GPIO - sysfs
# echo 510 > /sys/class/gpio/export
# echo "out" > /sys/class/gpio/gpio510/direction
# echo 0 > /sys/class/gpio/gpio510/value
# or
# echo low > /sys/class/gpio/gpio510/direction

# Clear GPIO - libgpiod
gpioset 0 29=0