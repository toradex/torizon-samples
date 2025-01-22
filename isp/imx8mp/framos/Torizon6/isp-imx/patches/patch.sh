#!/bin/sh

# Apply patches 
patch -d /downloads/isp-imx-${ISP_IMX_VERSION}/ -p1 < 0001-isp-imx-start_isp-don-t-report-error-if-no-camera-is.patch 
patch -d /downloads/isp-imx-${ISP_IMX_VERSION}/ -p1 < 0002-Add-support-for-imx6xx-sensors.patch 