﻿using System;
using System.Threading;
using NmeaParser;           // Provides NmeaMessage, NmeaMessage.Parse(), etc.
using NmeaParser.Messages;  // Provides Rmc, Gga, etc.
using System.IO.Ports;
using System.Threading.Tasks;

namespace gps
{
    class Program
    {
        static async Task Main(string[] args)
        {
            SerialPort serialDev;
            SerialPortDevice gps;

            // Configure the serial port
            serialDev = new SerialPort();
            /* 
            Example using Colibri board, in UART C interface. To check the available
            interfaces for your device, please check (remember to also update the
            docker-compose.yml file):
            https://developer.toradex.com/linux-bsp/application-development/peripheral-access/uart-linux
            */
            serialDev.PortName = "/dev/colibri-uartc";
            serialDev.BaudRate = 9600;

            // Initialize the GPS device using the library’s SerialPortDevice
            gps = new SerialPortDevice(serialDev);

            // Subscribe to the MessageReceived event
            gps.MessageReceived += OnNmeaMessageReceived;

            // Open the connection asynchronously
            await gps.OpenAsync();

            // On Ctrl+C, close the connection
            Console.CancelKeyPress += async (sender, eventArgs) =>
            {
                await gps.CloseAsync();
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
