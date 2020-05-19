using System;
using System.Text;
using System.IO.Ports;
using NmeaParser;
using NmeaParser.Messages;

namespace blazorGoogleMaps.Services
{
    public class GPS
    {
        private SerialPort serialDev;
        public SerialPortDevice Device { get; set; }
        public string ErrorMessage { get; set; }

        public GPS()
        {
            // initialize UART
            serialDev = new SerialPort();
            // WARNING: change the serial path to which corresponds to your module
            serialDev.PortName = "/dev/apalis-tty4";
            serialDev.BaudRate = 9600;
            Device = new SerialPortDevice(serialDev);
        }

        public async void Connect()
        {
            if (!Device.IsOpen)
            {
                try
                {
                    await Device.OpenAsync();
                }
                catch (Exception e)
                {
                    ErrorMessage = e.Message;
                }
            }
        }

        public void AddListener(EventHandler<NmeaMessageReceivedEventArgs> callback)
        {
            Device.MessageReceived += callback;
        }

        public void RemoveListener(EventHandler<NmeaMessageReceivedEventArgs> callback)
        {
            Device.MessageReceived -= callback;
        }
    }
}
