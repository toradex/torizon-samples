# GPIO C Sample

This sample interacts with GPIOs, in C, through `libgpiod2` .

In this sample, if no GPIO pin is defined it lists the GPIO pins on a GPIO
chip (in this example gpiochip0), and if the pin is defined it toggles the pin.