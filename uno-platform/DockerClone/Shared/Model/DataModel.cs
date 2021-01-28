using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace DockerClone
{
    public class DataModel : INotifyPropertyChanged
    {
        double _value = 0;

        public double Point { get; set; }
        public double Value
        {
            get
            {
                return _value;   
            }
            set
            {
                _value = value;
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Value)));
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;
    }
}
