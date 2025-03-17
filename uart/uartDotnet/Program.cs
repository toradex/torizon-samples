using System;
using System.Threading;
using NmeaParser;           // Provides NmeaMessage, NmeaMessage.Parse(), etc.
using NmeaParser.Messages;  // Provides Rmc, Gga, etc.
using System.IO.Ports;

namespace gps
{
    class Program
    {
        static void Main(string[] args)
        {
            SerialPort serialDev;
            SerialPortDevice gps;

            // Configure the serial port
            serialDev = new SerialPort();
            serialDev.PortName = Environment.GetEnvironmentVariable("GPS_SERIAL_PORT");
            serialDev.BaudRate = 9600;

            // Initialize the GPS device using the library’s SerialPortDevice
            gps = new SerialPortDevice(serialDev);

            // Subscribe to the MessageReceived event
            gps.MessageReceived += OnNmeaMessageReceived;

            // Open the connection asynchronously
            gps.OpenAsync();

            // On Ctrl+C, close the connection
            Console.CancelKeyPress += (sender, eventArgs) =>
            {
                gps.CloseAsync();
            };

            // Keep the application running indefinitely
            Thread.Sleep(Timeout.Infinite);
        }

        static void OnNmeaMessageReceived(object sender, NmeaMessageReceivedEventArgs args)
        {
            // When an RMC message is received, print latitude and longitude
            if (args.Message is Rmc rmc)
            {
                Console.WriteLine($"Latitude: {rmc.Latitude}\tLongitude: {rmc.Longitude}");
            }
        }
    }
}
