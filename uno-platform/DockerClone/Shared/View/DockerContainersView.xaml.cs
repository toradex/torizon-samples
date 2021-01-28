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

using Toradex.Utils;

namespace DockerClone
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class DockerContainersView : Page
    {
        List<FrameworkElement> hoverImages = new List<FrameworkElement>();
        List<Toradex.Utils.Docker.DockerContainerRecord> containers = new List<Toradex.Utils.Docker.DockerContainerRecord>();
        volatile bool StopUpdate = false;
        volatile int CheckUpdateInterval = 500;

        public DockerContainersView()
        {
            this.InitializeComponent();
        }

        public async void PageLoaded (object sender, RoutedEventArgs ev)
        {
            containers = await Toradex.Utils.Docker.GetContainers();
            checkContainers();

            ThreadPool.QueueUserWorkItem(async (obj) => {
                while (!StopUpdate) {
                    var _containers = await Toradex.Utils.Docker.GetContainers();
                    
                    if (_containers.Count != containers.Count) {
                        containers = _containers;
                        checkContainers();
                    } else {
                        for (var i = 0; i < containers.Count; i++) {
                            if (containers[i].State != _containers[i].State) {
                                containers = _containers;
                                checkContainers();
                            }
                        }
                    }

                    Thread.Sleep(CheckUpdateInterval);
                }
            });
        }

        public void PageUnloaded (object sender, RoutedEventArgs ev)
        {
            StopUpdate = true;
        }

        private void checkContainers()
        {   
            if (containers.Count > 0) {
                PanelInsideNoContainer.Visibility = Visibility.Collapsed;
                PanelInsideContainer.Visibility = Visibility.Visible;
                PanelContainerData.HorizontalAlignment = HorizontalAlignment.Stretch;
                PanelContainerData.VerticalAlignment = VerticalAlignment.Top;

                ListContainers.ItemsSource = containers;
            } else {
                PanelInsideContainer.Visibility = Visibility.Collapsed;
                PanelInsideNoContainer.Visibility = Visibility.Visible;
                PanelContainerData.HorizontalAlignment = HorizontalAlignment.Center;
                PanelContainerData.VerticalAlignment = VerticalAlignment.Center;
            }
        }

        public void ItemHover(object sender, PointerRoutedEventArgs e)
        {
            var item = (sender as ListViewItem);
            var img1 = (item.GetTemplateChild("ImgPlay") as Image);
            var img2 = (item.GetTemplateChild("ImgRefresh") as Image);
            var img3 = (item.GetTemplateChild("ImgRemove") as Image);
    
            // to make sure
            if (hoverImages.Count > 0 && hoverImages[0] != img1) {
                Animations.StopAll();
                foreach (var storedImg in hoverImages) {
                    Animations.ImageZoomOut(storedImg as Image, 0, 100);
                }
                hoverImages.Clear();
            } else if(hoverImages.Count > 0 && hoverImages[0] == img1) {
                return;
            }

            hoverImages.Add(img1);
            hoverImages.Add(img2);
            hoverImages.Add(img3);

            Animations.ImageZoomIn(img1, 1);
            Animations.ImageZoomIn(img2, 1);
            Animations.ImageZoomIn(img3, 1);
        }

        public void ClickRefresh(object sender, PointerRoutedEventArgs e)
        {
            var contName = (sender as Image).Tag.ToString();
            Toradex.Utils.Docker.RefreshContainer(contName, async () => {
                containers = await Toradex.Utils.Docker.GetContainers();
                checkContainers();
            });
        }

        public void ClickRemove(object sender, PointerRoutedEventArgs e)
        {
            var contName = (sender as Image).Tag.ToString();
            Toradex.Utils.Docker.RemoveContainer(contName, async () => {
                containers = await Toradex.Utils.Docker.GetContainers();
                checkContainers();
            });
        }

        public void ClickPlay(object sender, TappedRoutedEventArgs e)
        {
            var contName = (sender as Image).Tag.ToString();
            Toradex.Utils.Docker.StopContainer(contName, async () => {
                containers = await Toradex.Utils.Docker.GetContainers();
                checkContainers();
            });
        }
    }
}
