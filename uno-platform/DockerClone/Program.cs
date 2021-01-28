using System;
using GLib;
using Uno.UI.Runtime.Skia;

namespace DockerClone.Skia.Gtk
{
	class Program
	{
		static void Main(string[] args)
		{
			Toradex.Utils.Utils.LoggerFactory();
			
			ExceptionManager.UnhandledException += delegate (UnhandledExceptionArgs expArgs)
			{
				Console.WriteLine("GLIB UNHANDLED EXCEPTION" + expArgs.ExceptionObject.ToString());
				expArgs.ExitApplication = true;
			};

			var host = new GtkHost(() => new App(), args);

			host.Run();
		}
	}
}
