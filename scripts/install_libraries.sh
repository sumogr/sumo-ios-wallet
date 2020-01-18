#!/bin/bash

SOURCE_DIR=`pwd`
SCRIPTS_DIR="$SOURCE_DIR/scripts"
LIBRARY_DIR="$SOURCE_DIR/Libraries"

ZMQ_URL="https://raw.githubusercontent.com/zeromq/cppzmq/master/zmq.hpp"
ZMQ_PATH="/usr/local/include/zmq.hpp"

BOOST_URL="https://github.com/sumogr/ofxiOSBoost"
BOOST_DIR_PATH="$LIBRARY_DIR/boost"

OPEN_SSL_URL="https://github.com/x2on/OpenSSL-for-iPhone.git"
OPEN_SSL_DIR_PATH="$LIBRARY_DIR/openssl"

SODIUM_URL="https://github.com/jedisct1/libsodium"
SODIUM_PATH="$LIBRARY_DIR/sodium"

LMDB_DIR_URL="https://github.com/LMDB/lmdb.git"
LMDB_DIR_PATH="$LIBRARY_DIR/../lmdb/Sources"

SUMOKOIN_URL="https://github.com/sumogr/Sumokoin-ios"
SUMOKOIN_DIR_PATH="$LIBRARY_DIR/sumokoin"

echo "============================ ZMQ ============================"
if [ ! -f $ZMQ_PATH ]; then
    echo "Installing ZMQ"
    curl $ZMQ_DL_PATH -o $ZMQ_PATH
else
    echo "ZMQ already installed"
fi

echo "============================ Boost ============================"

sh $SCRIPTS_DIR/install_boost.sh

echo "============================ OpenSSL ============================"

echo "Cloning Open SSL from - $OPEN_SSL_URL"
git clone $OPEN_SSL_URL $OPEN_SSL_DIR_PATH
cd $OPEN_SSL_DIR_PATH
./build-libssl.sh --version=1.0.2j --archs="x86_64 arm64 armv7s armv7" --targets="ios-sim-cross-x86_64 ios64-cross-arm64 ios-cross-armv7s ios-cross-armv7"
cd $LIBRARY_DIR

echo "============================ LMDB ============================"
echo "Cloning lmdb from - $LMDB_DIR_URL"
git clone $LMDB_DIR_URL $LMDB_DIR_PATH
cd $LMDB_DIR_PATH
git checkout b9495245b4b96ad6698849e1c1c816c346f27c3c
cd $LIBRARY_DIR

echo "============================ SODIUM ============================"
echo "Cloning SODIUM from - $SODIUM_URL"
git clone $SODIUM_URL $SODIUM_PATH --branch stable
cd $SODIUM_PATH
./dist-build/ios.sh
cd $LIBRARY_DIR

echo "============================ SUMOKOIN ============================"

echo "Cloning sumokoin from - $SUMOKOIN_URL to - $SUMOKOIN_DIR_PATH"
git clone --recursive $SUMOKOIN_URL $SUMOKOIN_DIR_PATH

echo -e "\n Finished installing libraries"
