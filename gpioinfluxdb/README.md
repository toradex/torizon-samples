# GPIOInfluxDB

This sample is designed to be built using the Torizon extension for Visual Studio 2019 and used be running it from the debugger.

The sample will start also influxDB and grafana containers, on first run your target should be connected to the internet and will download the two additional containers required to run the sample, this may require some times (depending on connection speed).

Sample has been tested on Colibri imx7 and Apalis imx8, if you plan to use a different module you'll have to change the pin definitions at the beginning of main.cpp

Sample contains code from https://github.com/awegrzyn/influxdb-cxx.git, copied to build it together with the application code for simplicity.


