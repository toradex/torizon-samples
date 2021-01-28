using System;
using System.Threading;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using Toradex.Utils;
using Microsoft.Extensions.Logging;

namespace DockerClone.Model
{
    public class HardwareInfoViewModel
    {
        int bufferSize = 10;
        public IList<DiskUsageModel> Data { get; set; }
        public IList<CPUUsageModel> CPUData { get; set; }
        public IList<RAMUsageModel> RAMData { get; set; }

        public HardwareInfoViewModel()
        {
            // instance
            this.Data = new List<DiskUsageModel>();
            this.AdDiskUsage();

            this.CPUData = new List<CPUUsageModel>();
            this.RAMData = new List<RAMUsageModel>();
            
            for (var i = 0; i < bufferSize; i++) {
                this.CPUData.Add(new CPUUsageModel(){ Point = i, Value = 0 });
                this.RAMData.Add(new RAMUsageModel(){ Point = i, Value = 0 });
            }
        }

        public void AdDiskUsage ()
        {
            this.Data.Add(
                new DiskUsageModel() {
                    Name = "Free",
                    Count = HardwareInfo.GetStorageFreeSpace()
                }
            );

            this.Data.Add(
                new DiskUsageModel() {
                    Name = "In Use",
                    Count = (100 - HardwareInfo.GetStorageFreeSpace())
                }
            );
        }

        public void UpdateDiskUsage ()
        {
            var free = HardwareInfo.GetStorageFreeSpace();
            var inUse = (100 - HardwareInfo.GetStorageFreeSpace());

            this.Data[0].Count = free;
            this.Data[1].Count = inUse;
        }

        public void CPUCircularUpdate()
        {
            for (var i = 1; i < bufferSize; i++) {
                this.CPUData[i-1].Value = this.CPUData[i].Value;
            }

            this.CPUData[bufferSize -1].Value = HardwareInfo.GetCPUUsage();
        }

        public void RAMCircularUpdate()
        {
            for (var i = 1; i < bufferSize; i++) {
                this.RAMData[i-1].Value = this.RAMData[i].Value;
            }

            this.RAMData[bufferSize -1].Value = HardwareInfo.GetRAMUsage();
        }
    }
}
