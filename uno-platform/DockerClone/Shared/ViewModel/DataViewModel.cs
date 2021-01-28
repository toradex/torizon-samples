using System;
using System.Threading;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;

namespace DockerClone
{
    public class DataViewModel
    {
        int dataIx = 0;
        int bufferSize = 30;
        Random random;
        public IList<DataModel> Data { get; set; }

        public DataViewModel()
        {
            // instance
            random = new Random();
            this.Data = new List<DataModel>();
            
            for (var i = 0; i < bufferSize; i++) {
                this.Data.Add(new DataModel(){ Point = 0, Value = 0 });
            }
        }

        public void DataCircularUpdate()
        {
            if (dataIx == bufferSize) {
                dataIx = 0;
            }

            this.Data[dataIx].Value = (random.NextDouble() * 100);
            dataIx++;
        }
    }
}
