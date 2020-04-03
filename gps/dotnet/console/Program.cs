using System;
using System.Threading;
using NmeaParser;
using NmeaParser.Messages;
using System.IO.Ports;

namespace gps
{
    class Program
    {
        static void Main(string[] args)
        {
            SerialPort serialDev;
            SerialPortDevice gps;

            // serial configs
            serialDev = new SerialPort();
            serialDev.PortName = Environment.GetEnvironmentVariable("GPS_SERIAL_PORT");
            serialDev.BaudRate = 9600;
            gps = new SerialPortDevice(serialDev);

            // set listener
            gps.MessageReceived += OnNmeaMessageReceived;
            gps.OpenAsync();

            // on ctrl+c close connection
            Console.CancelKeyPress += (object sender, ConsoleCancelEventArgs eventArgs) =>
            {
                gps.CloseAsync();
            };

            // wait for gps inputs
            Thread.Sleep(Timeout.Infinite);
        }

        static void OnNmeaMessageReceived(object sender, NmeaMessageReceivedEventArgs args)
        {
            if (args.Message is Rmc rmc)
            {
                Console.WriteLine($"Latitude::{rmc.Latitude}\tLongitude::{rmc.Longitude}");
            }
        }
    }
}
