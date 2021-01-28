using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.IO;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Console;
using Toradex.Utils;
using ByteSizeLib;
using System.Threading.Tasks;
using NickStrupat;

namespace Toradex.Utils
{
    static public class HardwareInfo
    {
#pragma warning disable CA1416
        static PerformanceCounter perfCPU = new PerformanceCounter(
            "Processor",
            "% Processor Time",
            "_Total"
        );

        static PerformanceCounter perfRAM = new PerformanceCounter(
            "Memory",
            "Available MBytes",
        null);
#pragma warning restore CA1416

        static public int GetStorageFreeSpace ()
        {
            var drivers = DriveInfo.GetDrives();

            if (drivers.Length > 0) {
                var drive = drivers[0];

                return Convert.ToInt32(
                    (100 * drive.TotalFreeSpace) / drive.TotalSize
                );
            }

            return 0;
        }

        static public double GetCPUUsage ()
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                return perfCPU.NextValue();
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                var ret = "echo \"`LC_ALL=C top -bn1 | grep \"Cpu(s)\" | sed \"s/.*, *\\([0-9.]*\\)%* id.*/\\1/\" | awk '{print 100 - $1}'`\"".Bash();
                return double.Parse(ret.Trim().Replace("%", ""));
            }

            return 0;
        }

        static public double GetRAMUsage ()
        {
            var ci = new ComputerInfo();
            
            return 100d - (double)((100d * ci.AvailablePhysicalMemory) / ci.TotalPhysicalMemory);
        }
    }
}
