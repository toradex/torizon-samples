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

using System.Runtime.InteropServices;
using OSInfo = Microsoft.DotNet.PlatformAbstractions;

using Toradex.Utils;

namespace DockerClone
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class SystemInfoView : Page
    {
        public SystemInfoView()
        {
            this.InitializeComponent();

            // reset elements
            var sT = new ScaleTransform();
            sT.ScaleX = 0;
            sT.ScaleY = 0;
            ImageTorizonLogo.RenderTransform = sT;
            var sT1 = new ScaleTransform();
            sT1.ScaleX = 0;
            sT1.ScaleY = 0;
            ImageUnoLogo.RenderTransform = sT1;
            Animations.FadeOut(LabelBoard, 0, 1);
            Animations.FadeOut(LabelKernel, 0, 1);
            Animations.FadeOut(LabelTorizon, 0, 1);
            Animations.FadeOut(TextBoardVersion, 0, 1);
            Animations.FadeOut(TextKernelVersion, 0, 1);
            Animations.FadeOut(TextTorizonVersion, 0, 1);
            Animations.FadeOut(TextUno, 0, 1);
            TextKernelVersion.Margin = new Thickness(0,0);
            TextBoardVersion.Margin = new Thickness(0,0);
            TextTorizonVersion.Margin = new Thickness(0,0);
            TextUno.Margin = new Thickness(0,50,0,0);
        }

        public void PageLoaded (object sender, RoutedEventArgs ev)
        {
            // OS info
            TextTorizonVersion.Text =
                $"{OSInfo.RuntimeEnvironment.OperatingSystem} - {OSInfo.RuntimeEnvironment.OperatingSystemVersion}";
            // board info
            TextBoardVersion.Text =
                $"{RuntimeInformation.OSArchitecture} - {Utils.GetBoardName()}";
            // kernel info
            TextKernelVersion.Text = RuntimeInformation.OSDescription;

            if (OperatingSystem.IsWindows()) {
                ImageTorizonLogo.Source = "Assets/Images/windows.png";
            } else if (OperatingSystem.IsLinux()) {
                if (TextTorizonVersion.Text.IndexOf("ubuntu") != -1) {
                    ImageTorizonLogo.Source = "Assets/Images/ubuntu_logo.png";
                } else {
                    ImageTorizonLogo.Source = "Assets/Images/torizon_logo.png";
                }
            }

            // animate
            Animations.ImageZoomIn(ImageTorizonLogo, 1, 550, () =>
            {
                Animations.FadeIn(LabelBoard, 1, 250);
                Animations.FadeIn(LabelKernel, 1, 250);
                Animations.FadeIn(LabelTorizon, 1, 250);

                Animations.FadeFromRightWithSleeps(new[] {
                    TextBoardVersion,
                    TextTorizonVersion,
                    TextKernelVersion,
                }, new double[] {
                    1,
                    1,
                    1
                }, new double[] {
                    45,
                    45,
                    45
                }, 250, () => {
                    Animations.FadeFromRight(TextUno, 1, 45);
                    Animations.ImageZoomIn(ImageUnoLogo, 1, 250);
                });
            });
        }
    }
}
