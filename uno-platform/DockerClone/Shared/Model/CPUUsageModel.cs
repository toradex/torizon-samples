using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace DockerClone.Model
{
    public class CPUUsageModel : INotifyPropertyChanged
    {
        double _value = 0;

        public double Point { get; set; }
        //public double Value { get; set; }
        public double Value
        {
            get
            {
                return _value;   
            }
            set
            {
                _value = value;
                // we need this to "hot reload" the chart values
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Value)));
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
    }
}
