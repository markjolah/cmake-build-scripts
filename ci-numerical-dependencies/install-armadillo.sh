#!/bin/bash
# install-armadillo.sh <INSTALL_PREFIX>
#
# Download, configure and install armadillo.  If install prefix is omitted, defaults to root.
#
if [ -z "$1" ]; then
    INSTALL_PREFIX="/"
else
    INSTALL_PREFIX=$(realpath $1)
fi
if [ ! -d "$INSTALL_PREFIX" ]; then
    mkdir -p $INSTALL_PREFIX
fi

if [ -z "$FC" ]; then
    FC="gfortran"
fi

WORK_DIR=_work
PKG_NAME=armadillo
BUILD_PATH=_build
PKG_URL="https://gitlab.com/conradsnicta/armadillo-code.git"
PKG_BRANCH="9.300.x"
NUM_PROCS=$(grep -c ^processor /proc/cpuinfo)
REPOS_DIR=$WORK_DIR/$PKG_NAME

CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX"
CMAKE_ARGS="${CMAKE_ARGS} -DARMA_USE_HDF5=Off"
CMAKE_ARGS="${CMAKE_ARGS} ${@:2}"
if [ -d "${REPOS_DIR}" ]; then
    rm -rf $REPOS_DIR
fi
echo "using CMAKE_ARGS:${CMAKE_ARGS}"

set -ex
${FC} --version
mkdir -p $REPOS_DIR
cd $WORK_DIR
git clone $PKG_URL -b $PKG_BRANCH $PKG_NAME --depth 1
cd $PKG_NAME
if [ ! -d $BUILD_PATH ]; then
    mkdir -p ${BUILD_PATH}
fi
cmake -H$REPOS_DIR -B$BUILD_PATH  ${CMAKE_ARGS}
cd $BUILD_PATH
make all -- -j$NUM_PROCS
sudo make install
