#!/bin/bash

#
source /opt/Xilinx/14.7/ISE_DS/settings64.sh
#cd usb-driver-HEAD-2d19c7c/
#make
#sudo mkdir -p /usr/local/libusb-driver
#sudo cp libusb-driver.so /usr/local/libusb-driver/
export LD_PRELOAD=/usr/local/libusb-driver/libusb-driver.so
export XIL_IMPACT_USE_LIBUSB=1
./usb-driver-HEAD-2d19c7c/setup_pcusb /opt/Xilinx/14.7/ISE_DS/ISE/
sudo /etc/init.d/udev restart
