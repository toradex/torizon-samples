# ADC C Sample

This sample interacts with ADCs, in C, through the Industrial I/O (IIO) sysfs interface.

In this sample, the program reads the raw ADC value from a channel and calculates the voltage using the scale factor.

In the `docker-compose` file, we expose the necessary `/sys` directory:

```yaml
volumes:
  - type: bind
    source: /sys
    target: /sys
