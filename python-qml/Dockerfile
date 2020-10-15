ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG IMAGE_NAME=qt5-wayland
# For arm64 with Vivante use:
# ARG IMAGE_NAME=qt5-wayland-vivante
ARG APPNAME=show_readings.py

# One of the dependencies of the python-qml sample container is python3-pyside2.qtgui.
#
# Under Debian Bullseye, python3-pyside2.qtgui strictly depends on libqt5gui5 (>= 5.14).
# This looks to be a dangling dependency as libqt5gui5 appears twice in the dependency list of the package:
#
# $ apt-cache show python3-pyside2.qtgui | grep Depends
# Depends: python3 (<< 3.9), python3 (>= 3.8~), libc6 (>= 2.17), libgcc-s1 (>= 3.0), libpyside2-py3-5.15 (>= 5.15.0), libqt5core5a (>= 5.14), libqt5gui5 (>= 5.14), libqt5gui5 (>= 5.14.1) | libqt5gui5-gles (>= 5.14.1), libshiboken2-py3-5.15 (>= 5.15.0), libstdc++6 (>= 4.1.1), python3-pyside2.qtcore
#
# This is a problem in Vivante containers because libqt5gui5-gles replaces libqt5gui5 in these containers,
# forbidding the installation of dependent packages for the python-qml sample application.
#
# Let's work around by mangling the python3-pyside2.qtgui package and remove the libqt5gui5 dependency from it.
FROM --platform=$IMAGE_ARCH torizon/debian:2-bullseye AS package_fix
RUN apt-get update \
    && apt-get -y install --no-install-recommends binutils xz-utils \
    && apt-get download python3-pyside2.qtgui \
    && ar x python3-pyside2.qtgui_*.deb \
    && tar -xJf control.tar.xz \
    && sed -i '/^Depends:/s/, libqt5gui5 (>= 5.14)//' control \
    && tar -cJf control.tar.xz control md5sums \
    && ar rcs python3-pyside2.qtgui.deb debian-binary control.tar.xz data.tar.xz \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Build the sample python-qml container.
FROM --platform=$IMAGE_ARCH torizon/$IMAGE_NAME:2
ARG APPNAME

# Install the python3-pyside2.qtgui package with fixed dependencies.
COPY --from=package_fix python3-pyside2.qtgui.deb .
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends ./python3-pyside2.qtgui.deb \
    && rm ./python3-pyside2.qtgui.deb \
    && apt-mark hold python3-pyside2.qtgui \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Install further dependencies for the sample application.
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    python3 \
    qml-module-qtquick2 \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls \
    qml-module-qtquick-dialogs \
    python3-pyside2.qtcore \
    python3-pyside2.qtquick \
    python3-pyside2.qtwidgets \
    python3-pyside2.qtqml \
    python3-pyside2.qtnetwork \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
 
WORKDIR /

ENV ENVAPPNAME ${APPNAME}

COPY ./app /app

WORKDIR /app

CMD python3 $ENVAPPNAME
