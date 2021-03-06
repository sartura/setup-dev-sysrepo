#!/bin/sh

[ -z "$1" ] && echo "usage: setup-dev-sysrepo-legacy.sh <project-rootfs-dir-path>" && exit 1

set -e

START_DIR="$(pwd)"
SYSREPO_DIR="$1"

echo "Creating repositories: ${SYSREPO_DIR}/etc, ${SYSREPO_DIR}/etc/keystored, ${SYSREPO_DIR}/etc/keystored/keys, ${SYSREPO_DIR}/lib, ${SYSREPO_DIR}/repositories, ${SYSREPO_DIR}/repositories/plugins, ${SYSREPO_DIR}/var, ${SYSREPO_DIR}/var/run"
mkdir -p $SYSREPO_DIR/{etc,lib,repositories/plugins,var/run,/etc/keystored/keys}

echo

echo "Cloning repositories into ${SYSREPO_DIR}/repositories"
cd $SYSREPO_DIR/repositories

## pcre

wget https://netcologne.dl.sourceforge.net/project/pcre/pcre/8.43/pcre-8.43.zip
unzip pcre-8.43.zip && rm pcre-8.43.zip && cd pcre-8.43
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DBUILD_SHARED_LIBS=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON -DPCRE_SUPPORT_VALGRIND=ON ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## libyang

git clone https://github.com/CESNET/libyang.git && cd libyang
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## protobuf

git clone https://github.com/protocolbuffers/protobuf.git && cd protobuf
git submodule update --init --recursive
./autogen.sh
./configure --prefix=/opt/sysrepofs-legacy
make && make install
cd $SYSREPO_DIR/repositories

echo

## protobuf-c

git clone https://github.com/protobuf-c/protobuf-c.git && cd protobuf-c
./autogen.sh
PKG_CONFIG_PATH=$SYSREPO_DIR/lib/pkgconfig ./configure --prefix=$SYSREPO_DIR
make && make install
cd $SYSREPO_DIR/repositories

echo

## libev

wget http://dist.schmorp.de/libev/libev-4.33.tar.gz
tar -xzvf libev-4.33.tar.gz && rm libev-4.33.tar.gz && cd libev-4.33
sudo chmod +x autogen.sh && ./autogen.sh
./configure --prefix=$SYSREPO_DIR
make && make install
cd $SYSREPO_DIR/repositories

echo

## libredblack

git clone https://github.com/sysrepo/libredblack.git && cd libredblack
./configure --prefix=$SYSREPO_DIR
make || true
make install
cd $SYSREPO_DIR/repositories

echo

## libcmocka
git clone git://git.cryptomilk.org/projects/cmocka.git && cd cmocka
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## sysrepo

git clone https://github.com/sysrepo/sysrepo.git --branch legacy && cd sysrepo
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug -DIS_DEVELOPER_CONFIGURATION=true -DREPOSITORY_LOC=$SYSREPO_DIR/etc/sysrepo -DGEN_LANGUAGE_BINDINGS=OFF -DENABLE_TESTS=OFF ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## libssh

git clone http://git.libssh.org/projects/libssh.git && cd libssh
git checkout libssh-0.9.2
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## OpenSSL

git clone https://github.com/openssl/openssl.git && cd openssl
git checkout OpenSSL_1_1_1-stable
./config --prefix=$SYSREPO_DIR --openssldir=$SYSREPO_DIR/etc
make && make install
cd $SYSREPO_DIR/repositories

echo

## libnetconf2

git clone https://github.com/CESNET/libnetconf2.git --branch legacy && cd libnetconf2
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## Netopeer2

git clone https://github.com/CESNET/Netopeer2.git --branch legacy && cd Netopeer2
cd cli && mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd ../../

cd keystored && mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug -DKEYSTORED_KEYS_DIR=$SYSREPO_DIR/etc/keystored/keys -DSR_PLUGINS_DIR=$SYSREPO_DIR/lib/sysrepo/plugins ..
make -j2
LD_LIBRARY_PATH=$SYSREPO_DIR/lib make install
PATH=$PATH:$SYSREPO_DIR/bin LD_LIBRARY_PATH="/lib;$SYSREPO_DIR/lib" KEYSTORED_KEYS_DIR=$SYSREPO_DIR/etc/keystored/keys sh ../scripts/ssh-key-import.sh
cd ../../

cd server && mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug -DKEYSTORED_KEYS_DIR=$SYSREPO_DIR/etc/keystored/keys ..
make -j2
LD_LIBRARY_PATH=$SYSREPO_DIR/lib make install
cd $SYSREPO_DIR/repositories

echo

## libjson-c

git clone https://github.com/json-c/json-c.git && cd json-c
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## libubox

git clone https://git.lede-project.org/project/libubox.git && cd libubox
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX:PATH=$SYSREPO_DIR -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## libubus

git clone https://git.lede-project.org/project/ubus.git && cd ubus
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$SYSREPO_DIR -DBUILD_LUA=OFF -DBUILD_EXAMPLES=OFF ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## rpcd

git clone git://git.openwrt.org/project/rpcd.git && cd rpcd
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$SYSREPO_DIR -DFILE_SUPPORT=OFF -DRPCSYS_SUPPORT=OFF -DIWINFO_SUPPORT=OFF ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo

## libuci

git clone https://git.lede-project.org/project/uci.git && cd uci
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DBUILD_LUA=OFF ..
make -j2 && make install
cd $SYSREPO_DIR/repositories

echo


## plugins
echo "Cloning Sysrepo plugins into ${SYSREPO_DIR}/repositories/plugins"
cd $SYSREPO_DIR/repositories/plugins

echo

# sr_uci

git clone git@github.com:sartura/sr_uci.git && cd sr_uci
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2 && make install
cd $SYSREPO_DIR/repositories/plugins

echo

# dhcp

git clone git@github.com:sartura/dhcp.git && cd dhcp
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# provisioning-plugin

git clone git@github.com:sartura/provisioning-plugin.git && cd provisioning-plugin
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# firmware-plugin

git clone git@github.com:sartura/firmware-plugin.git && cd firmware-plugin
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# wireless-plugin

git clone git@github.com:sartura/wireless-plugin.git && cd wireless-plugin
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# sip-plugin

git clone git@github.com:sartura/sip-plugin.git && cd sip-plugin
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# network-plugin

git clone git@github.com:sartura/network-plugin.git && cd network-plugin
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# generic-ubus-plugin

git clone git@github.com:sartura/generic-ubus-plugin.git && cd generic-ubus-plugin
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# generic-ubus-yang-modules

git clone git@github.com:sartura/generic-ubus-yang-modules.git

echo

# firmware-plugin-openwrt

git clone git@github.com:sartura/firmware-plugin-openwrt.git && cd firmware-plugin-openwrt
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# wirless-plugin-openwrt

git clone git@github.com:sartura/wireless-plugin-openwrt.git && cd wireless-plugin-openwrt
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

# network-plugin-openwrt

git clone git@github.com:sartura/network-plugin-openwrt.git && cd network-plugin-openwrt
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_PREFIX_PATH=$SYSREPO_DIR -DCMAKE_INSTALL_PREFIX=$SYSREPO_DIR -DCMAKE_BUILD_TYPE=Debug ..
make -j2
cd $SYSREPO_DIR/repositories/plugins

echo

cd $START_DIR
unset SYSREPO_DIR

exit 0
