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

using Toradex.Utils;

namespace DockerClone
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class NotImplementedView : Page
    {
        public NotImplementedView()
        {
            this.InitializeComponent();

            // reset view
            var sT = new ScaleTransform();
            sT.ScaleX = 0;
            sT.ScaleY = 0;
            ImageWarningNotImplemented.RenderTransform = sT;
            Animations.FadeOut(TextWarningNotImplemented, 0, 1);
        }

        public void PageLoaded (object sender, RoutedEventArgs ev)
        {
            // animate
            Animations.ImageZoomIn(ImageWarningNotImplemented, 1, 500);
            Animations.FadeIn(TextWarningNotImplemented, 1, 500);
        }
    }
}

