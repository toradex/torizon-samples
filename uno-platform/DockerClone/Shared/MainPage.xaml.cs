using System;
using System.Threading;
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
using Microsoft.Extensions.Logging;

using System.Runtime.InteropServices;
using OSInfo = Microsoft.DotNet.PlatformAbstractions;

using Toradex.Utils;
using Windows.System;
using Uno.UI.Runtime.Skia;
using Windows.UI.Popups;

using System.ComponentModel;
using System.Collections.ObjectModel;
using System.Runtime.CompilerServices;

namespace DockerClone
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        public MainPage()
        {
            this.InitializeComponent();
        }

        private void docker()
        {
            try {
                Toradex.Utils.Docker.Connect();
                //TextDockerRunning.Text = await Toradex.Utils.Docker.GetVersion();
                //EllipseDocker.Fill = "#00d42a";
                DockerRunning.Background = "#6fcfb1";
            } catch (TimeoutException ex) {
                //TextDockerRunning.Text = ex.Message;
                //EllipseDocker.Fill = "#ffb300";
                Utils.Logger.LogError(ex.Message);
                DockerRunning.Background = "#d6c801";
            } catch (Exception e) {
                //TextDockerRunning.Text = e.Message;
                //EllipseDocker.Fill = "#d40000";
                Utils.Logger.LogError(e.Message);
                DockerRunning.Background = "#d40000";
            }
        }

        public void PageLoaded (object sender, RoutedEventArgs ev)
        {
            // get the username
            TextUserName.Text = Environment.UserName;

            // connect to Docker and check version
            docker();
            
            ContentFrame.Navigate(typeof(DockerContainersView));
        }

        public void ButtonClick(object sender, RoutedEventArgs env)
        {
            switch ((sender as Button).Tag.ToString())
            {
                case "imagesView":
                    ContentFrame.Navigate(typeof(DockerImagesView));
                break;
                case "containerView":
                    ContentFrame.Navigate(typeof(DockerContainersView));
                break;
                case "hardwareInfoView":
                    ContentFrame.Navigate(typeof(HardwareInfoView));
                break;
                default:
                    ContentFrame.Navigate(typeof(NotImplementedView));
                break;
            }
        }

        public void UserClick(object sender, RoutedEventArgs env)
        {
            ContentFrame.Navigate(typeof(SystemInfoView));
        }
    }
}
