using System;
using System.Threading;
using System.Device.Gpio;
using System.Device.Gpio.Drivers;

class Program
{
    static void Main()
    {
        int gpioLine = 7; //Equivalent to "SODIMM_55" on libgpiod (which is the
        // A0 pin on the Aster Carrier Board)
        int gpioChip = 0;// Equivalent to "/dev/gpiochip0"
        LibGpiodDriver gpiodDriver = new LibGpiodDriver(gpioChip);

        GpioController gpioController = new GpioController(PinNumberingScheme.Logical, gpiodDriver);

        gpioController.OpenPin(gpioLine, PinMode.Output);

        while (true)
        {
            gpioController.Write(gpioLine, PinValue.Low);
            Thread.Sleep(1000);
            gpioController.Write(gpioLine, PinValue.High);
            Thread.Sleep(1000);
        }
    }
}