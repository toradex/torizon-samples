# GPIO access using python

The sample shows how to use gpiod (installed via requirements.txt because debian provides an old release).  
Launching the application with no arguments will list all available chips and lines, passing a line (by setting the appargs property) will toggle the state of the selected line every second.