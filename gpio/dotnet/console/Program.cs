using System;
using System.Threading;
using System.Device.Gpio;
using System.Device.Gpio.Drivers;

namespace HelloWorld
{
    class Program
    {
        static int Main(string[] args)
        {
            // check arguments
            if (args.Length < 2)
            {
                Console.WriteLine("Usage ./HelloWorld GPIO-BANK GPIO-LINE");
                return -1;
            }

            int gpioBank = Int32.Parse(args[0]);
            int gpioLine = Int32.Parse(args[1]);

            // /dev/gpiochip[args[0]]
            LibGpiodDriver gpiodDriver = new LibGpiodDriver(gpioBank);
            GpioController gpioController = new GpioController(PinNumberingScheme.Logical, gpiodDriver);

            // open gpiochip[args[0]] line args[1]
            gpioController.OpenPin(gpioLine, PinMode.Output);

            while (true)
            {
                gpioController.Write(gpioLine, PinValue.Low);
                Thread.Sleep(500);
                gpioController.Write(gpioLine, PinValue.High);
                Thread.Sleep(500);
            }
        }
    }
}
