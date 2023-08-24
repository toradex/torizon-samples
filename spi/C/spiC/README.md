# SPI C Sample

This sample configures and uses the SPI communication protocol, through the 
`spidev` interface, on the User-Space. It uses the [source code for testing the spidev present in
the Linux Kernel](https://github.com/torvalds/linux/blob/v5.15/tools/spi/spidev_test.c).

In the case of this sample, it is interacting with the`/dev/verdin-spi-cs0` device interface.