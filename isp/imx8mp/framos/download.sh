#!/bin/bash

OPTION=$1
TORIZON_VERSION=$2
DRIVER_NAME=$3


check_version() {

    if [[ $TORIZON_VERSION == 6 ]]; then
        TDX_BRANCH="toradex_5.15-2.2.x-imx"
        META_TDX_FRAMOS_BRANCH="kirkstone-6.x.y"
    elif [[ $TORIZON_VERSION == 7 ]]; then
        TDX_BRANCH="toradex_6.6-2.1.x-imx"
        META_TDX_FRAMOS_BRANCH="scarthgap-7.x.y"
    else
        echo "Error: Invalid TorizonOS version!"
        exit 1
    fi
}

download_linux_dt() {
    
    check_version
    echo "download_linux_dt"
   
    rm -rf linux
    rm -rf device-trees

    git clone --depth 3 -b $TDX_BRANCH $T git://git.toradex.com/linux-toradex.git linux
    git clone --depth 3 -b $TDX_BRANCH git://git.toradex.com/device-tree-overlays.git device-trees
}

download_driver() {
    echo "download_driver"
    check_version
    if [[ $DRIVER_NAME == "imx662" || $DRIVER_NAME == "imx676" || $DRIVER_NAME == "imx678" ]]; then
        rm -rf $DRIVER_NAME-driver
        rm -f "device-trees/overlays/verdin-imx8mp_${DRIVER_NAME}_overlay.dts" 

        wget -P "${DRIVER_NAME}-driver" "https://raw.githubusercontent.com/framosimaging/framos-nxp-drivers/3bb0c957a4e14143451b119d030e39f783767b31/isp-vvcam/vvcam/v4l2/sensor/${DRIVER_NAME}/${DRIVER_NAME}_mipi.c"
        wget -P "${DRIVER_NAME}-driver" "https://raw.githubusercontent.com/framosimaging/framos-nxp-drivers/3bb0c957a4e14143451b119d030e39f783767b31/isp-vvcam/vvcam/v4l2/sensor/${DRIVER_NAME}/${DRIVER_NAME}_regs.h"
        wget -P "${DRIVER_NAME}-driver" "https://raw.githubusercontent.com/framosimaging/framos-nxp-drivers/3bb0c957a4e14143451b119d030e39f783767b31/isp-vvcam/vvcam/common/vvsensor.h"
        wget -P "${DRIVER_NAME}-driver" "https://raw.githubusercontent.com/toradex/meta-toradex-framos/${META_TDX_FRAMOS_BRANCH}/recipes-kernel/${DRIVER_NAME}/files/Makefile"
        wget -P "device-trees/overlays" "https://raw.githubusercontent.com/toradex/meta-toradex-framos/${META_TDX_FRAMOS_BRANCH}/recipes-kernel/linux/device-tree-overlays/verdin-imx8mp_${DRIVER_NAME}_overlay.dts"

    else
        echo "no sensor specified! Possible options:"
        echo "imx662"
        echo "imx676"
        echo "imx678"
        
        exit 1
    fi
}

clean_all() {
    echo "clean_all"

    rm -rf linux
    rm -rf device-trees
    rm -rf imx*-driver
}

usage() {
    echo "Usage:"
    
    echo " Download Linux and device-tree-overlays repository: "
    echo " linux [TORIZON OS VERSION]"
    echo " examples: ./download linux 6 (For TorizonOS 6)"
    echo "           ./download linux 7 (For TorizonOS 7)"
    echo ""

    echo " driver [TORIZON OS VERSION] [DRIVER NAME]: download driver source code"
    echo " examples: ./download.sh driver 6 imx662 (Driver for IMX662, TorizonOS 6)"
    echo "           ./download.sh driver 7 imx678 (Driver for IMX678, TorizonOS 7)"
    echo ""
    echo " clean: delete all downloaded folders"
}

case "$1" in
    linux)
        download_linux_dt
        ;;
    driver)
        download_driver
        ;;
    clean)
        clean_all
        ;;
    *)
        usage
        exit 1
esac
