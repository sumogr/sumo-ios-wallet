#!/bin/bash

SOURCE_DIR=`pwd`
LIBRARY_DIR="$SOURCE_DIR/Libraries"

SUMOKOIN_DIR_PATH="$LIBRARY_DIR/sumokoin"
BOOST_DIR_PATH="$LIBRARY_DIR/boost"
OPEN_SSL_DIR_PATH="$LIBRARY_DIR/openssl"
SODIUM_PATH="$LIBRARY_DIR/sodium"

USR_INCLUDES="/usr/local/include"

echo "============================ Building Sumokoin iOS ============================"

cd $LIBRARY_DIR

echo "Export Boost vars"
BOOST_LIBRARYDIR="$BOOST_DIR_PATH/build/ios/prefix/lib"
BOOST_LIBRARYDIR_x86_64="$BOOST_DIR_PATH/build/libs/boost/lib/x86_64"
BOOST_INCLUDEDIR="$BOOST_DIR_PATH/build/ios/prefix/include"

echo "Export OpenSSL vars"
OPENSSL_INCLUDE_DIR="$OPEN_SSL_DIR_PATH/include"
OPENSSL_ROOT_DIR="$OPEN_SSL_DIR_PATH/lib"

echo "Export Sodium vars"
SODIUM_LIBRARY="$SODIUM_PATH/libsodium-ios/lib/libsodium.a"
SODIUM_INCLUDE="$SODIUM_PATH/libsodium-ios/include"

# Hack to get cmake to find sodium
export CPLUS_INCLUDE_PATH=$BOOST_INCLUDEDIR:$SODIUM_INCLUDE:$USR_INCLUDES

if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=release
fi

if [ -z $INSTALL_PREFIX ]; then
    INSTALL_PREFIX=$SUMOKOIN_DIR_PATH
fi

mkdir -p sumokoin/build

echo "Building IOS armv7"
rm -r sumokoin/build > /dev/null
mkdir -p sumokoin/build/release
pushd lsumokoin/build/release
cmake -D IOS=ON -D ARCH=armv7 -D BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR} -D BOOST_INCLUDEDIR=${BOOST_INCLUDEDIR} -D OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} -D OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -D CMAKE_BUILD_TYPE=debug -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D SODIUM_LIBRARY=$SODIUM_LIBRARY -D SODIUM_INCLUDE_DIR=$SODIUM_INCLUDE -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX  ../..
make -j4 && make install
popd

echo "Building IOS arm64"
rm -r sumokoin/build > /dev/null
mkdir -p sumokoin/build/release
pushd sumokoin/build/release
cmake -D IOS=ON -D ARCH=arm64 -D BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR} -D BOOST_INCLUDEDIR=${BOOST_INCLUDEDIR} -D OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} -D OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -D CMAKE_BUILD_TYPE=debug -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D SODIUM_LIBRARY=$SODIUM_LIBRARY -D SODIUM_INCLUDE_DIR=$SODIUM_INCLUDE -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX  ../..
make -j4 && make install
popd

echo "Building IOS x86"
rm -r sumokoin/build > /dev/null
mkdir -p sumokoin/build/release
pushd sumokoin/build/release
cmake -D IOS=ON -D ARCH=x86_64 -D IOS_PLATFORM=SIMULATOR64 -D BOOST_LIBRARYDIR=${BOOST_LIBRARYDIR_x86_64} -D BOOST_INCLUDEDIR=${BOOST_INCLUDEDIR} -D OPENSSL_INCLUDE_DIR=${OPENSSL_INCLUDE_DIR} -D OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} -D CMAKE_BUILD_TYPE=debug -D STATIC=ON -D BUILD_GUI_DEPS=ON -D INSTALL_VENDORED_LIBUNBOUND=ON -D SODIUM_LIBRARY=$SODIUM_LIBRARY -D SODIUM_INCLUDE_DIR=$SODIUM_INCLUDE -D CMAKE_INSTALL_PREFIX=$INSTALL_PREFIX  ../..
make -j4 && make install
popd

echo "Creating fat library for armv7 and arm64"
pushd sumokoin
mkdir -p lib-ios
lipo -create lib-armv7/libwallet_merged.a lib-x86_64/libwallet_merged.a lib-armv8-a/libwallet_merged.a -output lib-ios/libwallet_merged.a
lipo -create lib-armv7/libunbound.a lib-x86_64/libunbound.a lib-armv8-a/libunbound.a -output lib-ios/libunbound.a
lipo -create lib-armv7/libepee.a lib-x86_64/libepee.a lib-armv8-a/libepee.a -output lib-ios/libepee.a
lipo -create lib-armv7/libeasylogging.a lib-x86_64/libeasylogging.a lib-armv8-a/libeasylogging.a -output lib-ios/libeasylogging.a
popd

cd ..