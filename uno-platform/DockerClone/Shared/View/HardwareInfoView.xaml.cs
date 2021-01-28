using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

using DockerClone.Model;
using Toradex.Utils;
using Microsoft.Extensions.Logging;
using System.Threading;
using Syncfusion.UI.Xaml.Charts;

namespace DockerClone
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class HardwareInfoView : Page
    {
        public HardwareInfoViewModel ViewModel { get; set; }
        volatile bool StopUpdateCharts = false;
        volatile int CheckUpdateInterval = 500;

        public HardwareInfoView()
        {
            this.InitializeComponent();

            if (!App.FullResolution) {
                CPUChart.Width -= 100;
                CPUChart.Height -= 100;
                RAMChart.Width -= 100;
                RAMChart.Height -= 100;
                ChartDiskUsage.Width -= 100;
                ChartDiskUsage.Height -= 100;
            }
        }

        public void PageLoaded (object sender, RoutedEventArgs ev)
        {
            ViewModel = new HardwareInfoViewModel();
            this.DataContext = ViewModel;

            // start updates
            ThreadPool.QueueUserWorkItem(UpdateCharts);
            Utils.Logger.LogInformation($"{this.GetType().Name} Loaded");
        }

        public void PageUnloaded (object sender, RoutedEventArgs ev)
        {
            // stop updates
            StopUpdateCharts = true;
            Utils.Logger.LogInformation($"{this.GetType().Name} Unloaded");
        }

        private void UpdateCharts(object stateInfo)
        {
            while (!StopUpdateCharts) {
                ViewModel.UpdateDiskUsage();
                ViewModel.CPUCircularUpdate();
                ViewModel.RAMCircularUpdate();
                Thread.Sleep(CheckUpdateInterval);
                /*System.GC.Collect(GC.MaxGeneration, GCCollectionMode.Forced);
                System.GC.WaitForPendingFinalizers();
                System.GC.Collect();*/
            }
        }
    }
}
