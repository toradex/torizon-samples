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
using Windows.UI.Xaml.Media.Animation;
using Windows.UI.Xaml.Navigation;

using System.Threading;

namespace Toradex.Utils
{
    public class Animations
    {
        public static List<Storyboard> animations = new List<Storyboard>();

        public static void ImageZoomIn(Image target, double to,
            int durationMilliseconds = 250, Action endFunc = null)
        {
            Storyboard st = new Storyboard();
            IEasingFunction easing= new QuadraticEase() {
                EasingMode = EasingMode.EaseIn
            };
            DoubleAnimation dax = new DoubleAnimation(){
                To = to,
                Duration= TimeSpan.FromMilliseconds(durationMilliseconds),
                EasingFunction = easing
            };
            DoubleAnimation day = new DoubleAnimation(){
                To = to,
                Duration= TimeSpan.FromMilliseconds(durationMilliseconds),
                EasingFunction = easing
            };

            Storyboard.SetTarget(dax, target);
            Storyboard.SetTargetProperty(dax,
                new PropertyPath("(Image.RenderTransform).(ScaleTransform.ScaleX)"));
            Storyboard.SetTarget(day, target);
            Storyboard.SetTargetProperty(day,
                new PropertyPath("(Image.RenderTransform).(ScaleTransform.ScaleY)"));

            st.Children.Add(dax);
            st.Children.Add(day);
            animations.Add(st);
            st.Begin();

            st.Completed += (obj, e) => {
                endFunc?.Invoke();
                animations.Remove(st);
            };
        }

        public static void ImageZoomOut(Image target, double to,
            int durationMilliseconds = 250, Action endFunc = null)
        {
            Storyboard st = new Storyboard();
            IEasingFunction easing= new QuadraticEase() {
                EasingMode = EasingMode.EaseOut
            };
            DoubleAnimation dax = new DoubleAnimation(){
                To = to,
                Duration= TimeSpan.FromMilliseconds(durationMilliseconds),
                EasingFunction = easing
            };
            DoubleAnimation day = new DoubleAnimation(){
                To = to,
                Duration= TimeSpan.FromMilliseconds(durationMilliseconds),
                EasingFunction = easing
            };

            Storyboard.SetTarget(dax, target);
            Storyboard.SetTargetProperty(dax,
                new PropertyPath("(Image.RenderTransform).(ScaleTransform.ScaleX)"));
            Storyboard.SetTarget(day, target);
            Storyboard.SetTargetProperty(day,
                new PropertyPath("(Image.RenderTransform).(ScaleTransform.ScaleY)"));

            st.Children.Add(dax);
            st.Children.Add(day);
            animations.Add(st);
            st.Begin();

            st.Completed += (obj, e) => {
                endFunc?.Invoke();
                animations.Remove(st);
            };
        }

        public static void ZoomInWithSleeps(Image[] elements, double[] tos, int sleep)
        {
            (new Thread(() => {
                for (var i = 0; i < elements.Length; i++)
                {
                    Animations.ImageZoomIn(elements[i], tos[i]);
                    Thread.Sleep(sleep);
                }
            })).Start();
        }

        public static void ZoomOutWithSleeps(Image[] elements, double[] tos,
            int sleep, Action endFunc = null)
        {
            (new Thread(() => {
                for (var i = 0; i < elements.Length; i++)
                {
                    Animations.ImageZoomOut(elements[i], tos[i]);
                    Thread.Sleep(sleep);
                }

                endFunc?.Invoke();
            })).Start();
        }

        public static void StopAll()
        {
            foreach (var st in animations) {
                st.Stop();
            }
            animations.Clear();
        }

        public static void Fade(FrameworkElement elem, double to,
            int duration, Action endFunc, EasingMode easeMode)
        {
            Storyboard st = new Storyboard();
            IEasingFunction easing= new QuadraticEase() {
                EasingMode = easeMode
            };
            DoubleAnimation dax = new DoubleAnimation(){
                To = to,
                Duration= TimeSpan.FromMilliseconds(duration),
                EasingFunction = easing
            };

            Storyboard.SetTarget(dax, elem);
            Storyboard.SetTargetProperty(dax, new PropertyPath("Opacity"));

            st.Children.Add(dax);
            animations.Add(st);
            st.Begin();

            st.Completed += (obj, e) => {
                endFunc?.Invoke();
                animations.Remove(st);
            };
        }

        public static void FadeOut(FrameworkElement elem, double to,
            int duration, Action endFunc = null,
            EasingMode easeMode = EasingMode.EaseOut)
        {
            Fade(elem, to, duration, endFunc, easeMode);
        }

        public static void FadeIn(FrameworkElement elem, double to,
            int duration, Action endFunc = null,
            EasingMode easeMode = EasingMode.EaseIn)
        {
            Fade(elem, to, duration, endFunc, easeMode);
        }

        public static void FadeFromRight(FrameworkElement elem, double toOpacity,
            double toLeft, int duration = 250, Action endFunc = null)
        {
            // well no way to set only the left so let's try on my own
            var stOwn = new Thread(() => {
                var actual = elem.Margin.Left;
                var steps = Math.Abs(actual - toLeft);
                var interval = duration / steps;

                for (var i = 0; i < steps; i++)
                {
                    actual++;
                    elem.Margin = new Thickness(actual, 0);
                    Thread.Sleep((int)interval);
                }
            });

            Storyboard st = new Storyboard();
            IEasingFunction easing= new QuadraticEase() {
                EasingMode = EasingMode.EaseOut
            };
            DoubleAnimation dax = new DoubleAnimation(){
                To = toOpacity,
                Duration= TimeSpan.FromMilliseconds(duration),
                EasingFunction = easing
            };

            Storyboard.SetTarget(dax, elem);
            Storyboard.SetTargetProperty(dax, new PropertyPath("Opacity"));

            st.Children.Add(dax);
            st.Begin();
            stOwn.Start();

            st.Completed += (obj, e) => {
                endFunc?.Invoke();
            };
        }

        public static void FadeFromRightWithSleeps(FrameworkElement[] elements,
            double[] tosOpacity, double[] tosLeft, int sleep, Action endFunc = null)
        {
            (new Thread(() => {
                for (var i = 0; i < elements.Length; i++)
                {
                    Animations.FadeFromRight(
                        elements[i],
                        tosOpacity[i],
                        tosLeft[i]
                    );
                    Thread.Sleep(sleep);
                }

                endFunc?.Invoke();
            })).Start();
        }
    }
}
