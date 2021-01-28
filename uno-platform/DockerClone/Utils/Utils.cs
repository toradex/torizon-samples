using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Console;

namespace Toradex.Utils
{
    public static class Utils
    {
        private static ILoggerFactory loggerFactory = null;
        public static ILogger Logger;

        public static void LoggerFactory()
        {
            if (loggerFactory == null) {
                loggerFactory = new LoggerFactory();
                loggerFactory.AddProvider(new ConsoleLoggerProvider((_, __) => true, true));
                Logger = loggerFactory.CreateLogger("Toradex");

                Logger.LogInformation("Logger enabled");
            }
        }

        public static string GetBoardName()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows) ||
                (RuntimeInformation.IsOSPlatform(OSPlatform.Linux) && 
                !(RuntimeInformation.OSArchitecture == Architecture.Arm ||
                    RuntimeInformation.OSArchitecture == Architecture.Arm64))
            ) {
                return Environment.MachineName;
            } else {
                var fdt = Shell("cat /proc/device-tree/model");
                return fdt.Remove(fdt.Length -1);
            }
        }

        public static string Shell(this string cmd)
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
                return Pwsh(cmd);
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                return Bash(cmd);

            return null;
        }

        public static string Bash(this string cmd)
        {
            var escapedArgs = cmd.Replace("\"", "\\\"");
            
            var process = new Process()
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "/bin/bash",
                    Arguments = $"-c \"{escapedArgs}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                }
            };
            process.Start();
            string result = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            return result;
        }

        public static string Pwsh(this string cmd)
        {
            var escapedArgs = cmd.Replace("\"", "\\\"");
            
            var process = new Process()
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = "c:\\Program Files\\PowerShell\\7\\pwsh.exe",
                    Arguments = $"-c \"{escapedArgs}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                }
            };
            process.Start();
            string result = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            return result;
        }

        public static string GetTimeSince(DateTime objDateTime)
        {
            // https://www.thatsoftwaredude.com/content/1019/how-to-calculate-time-ago-in-c
            TimeSpan ts = DateTime.Now.ToUniversalTime().Subtract(objDateTime);
            int intDays = ts.Days;
            int intHours = ts.Hours;
            int intMinutes = ts.Minutes;
            int intSeconds = ts.Seconds;

            if (intDays > 0)
                return string.Format("{0} days ago", intDays);

            if (intHours > 0)
                return string.Format("{0} hours ago", intHours);

            if (intMinutes > 0)
                return string.Format("{0} minutes ago", intMinutes);

            if (intSeconds > 0)
                return string.Format("{0} seconds ago", intSeconds);

            // let's handle future times..just in case
            if (intDays < 0)
                return string.Format("in {0} days", Math.Abs(intDays));

            if (intHours < 0)
                return string.Format("in {0} hours", Math.Abs(intHours));

            if (intMinutes < 0)
                return string.Format("in {0} minutes", Math.Abs(intMinutes));

            if (intSeconds < 0)
                return string.Format("in {0} seconds", Math.Abs(intSeconds));

            return "a bit";
        }

        public static string LimitLength(this string source, int maxLength)
        {
            if (source.Length <= maxLength)
            {
                return source;
            }

            return source.Substring(0, maxLength);
        }
    }
}
