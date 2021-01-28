using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace DockerClone.Model
{
    public class DiskUsageModel : INotifyPropertyChanged
    {
        int count = 0;

        public string Name { get; set; }
        public int Count
        {
            get
            {
                return count;   
            }
            set
            {
                count = value;
                // we need this to "hot reload" the chart values
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Count)));
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
    }
}
