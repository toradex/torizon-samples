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
using Windows.System;
using Uno.UI.Runtime.Skia;

using Toradex.Utils;

namespace DockerClone
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class DockerImagesView : Page
    {
        private List<FrameworkElement> hoverBtns = new List<FrameworkElement>();
        private List<Toradex.Utils.Docker.DockerImageRecord> images = new List<Toradex.Utils.Docker.DockerImageRecord>();
        volatile bool StopUpdate = false;
        volatile int CheckUpdateInterval = 500;

        public DockerImagesView()
        {
            this.InitializeComponent();

            // resize listviews
            this.SizeChanged += (obj, args) => {
                int h, w;
                GtkHost.Window.GetSize(out w, out h);
                ListImages.Height = (h - 340);
            };
        }

        private void CheckImages()
        {
            Toradex.Utils.Docker.UpdateSystemInfoDf();
            var totalSize = Toradex.Utils.Docker.GetImagesTotalSize();
            var reclaimable = Toradex.Utils.Docker.GetImagesReclaimable();

            TextCountImages.Text = $"{images.Count} images";
            TextImagesTotalSize.Text = $"Total Size: {totalSize}";
            ProgressReclaimable.Value = 100 - reclaimable;

            ListImages.ItemsSource = images;
        }

        public async void PageLoaded (object sender, RoutedEventArgs ev)
        {
            images = await Toradex.Utils.Docker.GetImages();
            CheckImages();

            ThreadPool.QueueUserWorkItem(async (obj) => {
                while(!StopUpdate) {
                    var _images = await Toradex.Utils.Docker.GetImages();

                    if (images.Count != _images.Count) {
                        images = _images;
                        CheckImages();
                    }

                    Thread.Sleep(CheckUpdateInterval);
                }
            });
        }

        public void PageUnloaded (object sender, RoutedEventArgs ev)
        {
            StopUpdate = true;
        }

        public void InputSearch(object sender, KeyRoutedEventArgs e)
        {
            Console.WriteLine(e.Key);
            
            if (e.Key.ToString().Length == 1)
                TextInputSearch.PlaceholderText += e.Key;
            else if (e.Key == VirtualKey.Back)
                TextInputSearch.PlaceholderText =
                    TextInputSearch.PlaceholderText
                        .Remove(TextInputSearch.PlaceholderText.Length -1);
        }

        public void ItemHover(object sender, PointerRoutedEventArgs e)
        {
            var item = (sender as ListViewItem);
            var btn = (item.GetTemplateChild("BtnRemove") as Button);
    
            // to make sure
            if (hoverBtns.Count > 0 && hoverBtns[0] != btn) {
                Animations.StopAll();
                foreach (var storedBtn in hoverBtns) {
                    if (storedBtn != btn) {
                        Animations.FadeOut(storedBtn, 0, 200);
                        Animations.FadeOut(VisualTreeHelper
                            .GetChild(((storedBtn as Button).Content as StackPanel), 0) as Image,
                                        0, 200);
                    }
                }
                hoverBtns.Clear();
            } else if(hoverBtns.Count > 0 && hoverBtns[0] == btn) {
                return;
            }

            hoverBtns.Add(btn);
            Animations.FadeIn(btn, 1, 250);
            Animations.FadeIn(VisualTreeHelper
                .GetChild((btn.Content as StackPanel), 0) as Image, 0.2, 250);
        }

        public void RemoveImage(object sender, RoutedEventArgs e)
        {
            var id = (sender as Button).Tag.ToString();
            Console.WriteLine(id);
            
            // TODO add a complete message
            Toradex.Utils.Docker.RemoveImage(id, () => {
                PageLoaded(null, null);
            });
        }
    }
}
