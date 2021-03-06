#!/usr/bin/env bash

set -u

# http://packages.ubuntu.com/precise/gcc-arm-linux-gnueabihf

export MP_PLATFORM="Linaro-softfp"
export HOST_PLATFORM="Linux" # assumed to be Ubuntu
export BOOST_ARCH="arm"
export ARCH_NAME="gcc-arm-linux-gnueabi"
export HOST_ARG="--host=arm-linux-gnueabi"
source $(dirname "$BASH_SOURCE")/settings.sh
export MAKE="make"
