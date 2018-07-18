#!/bin/bash
set -e # immediately if a command exits with a non-zero status.

# settings
# DEV_GROUP=lede
# TARGET_ARCHITECTURE=ar71xx
# TARGET_VARIANT=generic
# TARGET_DEVICE=tl-wr710n-v1
# RELEASE="17.01.4"

DEV_GROUP=openwrt
TARGET_ARCHITECTURE=ramips
TARGET_VARIANT=mt76x8
TARGET_DEVICE=tplink_tl-wr902ac-v3
RELEASE="18.06.0-rc1"

# EXCLUDE PACKAGES
# PKG=" -ip6tables"
# PKG+=" -kmod-ip6tables"
# PKG+=" -kmod-ipv6"
# PKG+=" -kmod-ppoe"
# PKG+=" -kmod-ppp"
# PKG+=" -kmod-pppox"
# PKG+=" -libip6tc"
# PKG+=" -libip6tc"
# PKG+=" -odhcp6c"
# PKG+=" -ppp"
# PKG+=" -ppp-mod-pppoe"

# INCLUDE PACKAGES
# PKG+=" block-mount"
# PKG+=" e2fsprogs"
# PKG+=" fdisk"
# PKG+=" kmod-fs-ext4"
# PKG+=" kmod-scsi-core"
# PKG+=" kmod-scsi-generic"
# PKG+=" kmod-usb-core"
# PKG+=" kmod-usb-net-cdc-ether"
# PKG+=" kmod-usb-ohci"
# PKG+=" kmod-usb-storage"
# PKG+=" kmod-usb-uhci"
# PKG+=" kmod-usb2"
# PKG+=" partx-utils"
# PKG+=" luci"
PKG+=" uhttpd"
PKG+=" php7"
PKG+=" php7-cgi"
PKG+=" openssh-sftp-server"
PKG+=" iwinfo"
PKG+=" rsync"
PKG+=" kmod-usb-acm"
PKG+=" kmod-usb-serial-ch341"
# PKG+=" libstdcpp"
# PKG+=" print3d"
PKG+=" avahi-daemon-service-http"


BUILD_FOLDER=imagebuilder
IMAGEBUILDER_NAME="$DEV_GROUP-imagebuilder-${RELEASE}-${TARGET_ARCHITECTURE}-${TARGET_VARIANT}.Linux-x86_64"
IMAGEBUILDER_DIR="${BUILD_FOLDER}/${IMAGEBUILDER_NAME}"
IMAGEBUILDER_ARCHIVE="${IMAGEBUILDER_NAME}.tar.xz"
IMAGEBUILDER_URL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET_ARCHITECTURE}/${TARGET_VARIANT}/${IMAGEBUILDER_ARCHIVE}"

FIRMWARE_FOLDER=${IMAGEBUILDER_DIR}/bin/targets/${TARGET_ARCHITECTURE}/${TARGET_VARIANT}
FIRMWARE_NAME=$DEV_GROUP-$RELEASE-$TARGET_ARCHITECTURE-$TARGET_VARIANT-${TARGET_DEVICE}-squashfs-factory.bin

#download image builder if needed
if [ ! -e ${IMAGEBUILDER_DIR} ]; then
    pushd ${BUILD_FOLDER}
    wget  --continue ${IMAGEBUILDER_URL}     # --no-check-certificate if needed
    xz -d <${IMAGEBUILDER_ARCHIVE} | tar vx
    popd
fi

# remove previous build results (-f surpress error if not exists)
rm -f ${FIRMWARE_FOLDER}/*
rm -f bin/*

# copy custom ipk's (not the right way... how can this be done better?)
cp custom-packages/*.ipk ${IMAGEBUILDER_DIR}/packages

# build
pushd ${IMAGEBUILDER_DIR}
make image PROFILE=${TARGET_DEVICE} PACKAGES="$PKG" FILES=../../files
popd

# create symlinks
pushd bin
ln -s ../${FIRMWARE_FOLDER}/${FIRMWARE_NAME} .
ln -s ../${FIRMWARE_FOLDER}/${FIRMWARE_NAME} latest.bin
popd






