#!/bin/bash
set -e # immediately if a command exits with a non-zero status.

TARGET_ARCHITECTURE=ar71xx
TARGET_VARIANT=generic
TARGET_DEVICE=tl-wr710n-v1
RELEASE="17.01.4"

absolutize ()
{
  if [ ! -d "$1" ]; then
    echo
    echo "ERROR: '$1' doesn't exist or not a directory!"
    kill -INT $$
  fi

  pushd "$1" >/dev/null
  echo `pwd`
  popd >/dev/null
}

ROOT=`pwd`
BUILD=$ROOT/imagebuilder/
BUILD=`absolutize $BUILD`

IMGBUILDER_NAME="lede-imagebuilder-${RELEASE}-${TARGET_ARCHITECTURE}-${TARGET_VARIANT}.Linux-x86_64"
IMGBUILDER_DIR="${BUILD}/${IMGBUILDER_NAME}"
IMGBUILDER_ARCHIVE="${IMGBUILDER_NAME}.tar.xz"
IMGBUILDERURL="https://downloads.openwrt.org/releases/${RELEASE}/targets/${TARGET_ARCHITECTURE}/${TARGET_VARIANT}/${IMGBUILDER_ARCHIVE}"

#download image builder if needed
if [ ! -e ${IMGBUILDER_DIR} ]; then
    pushd ${BUILD}
    wget  --continue ${IMGBUILDERURL}     # --no-check-certificate if needed
    xz -d <${IMGBUILDER_ARCHIVE} | tar vx
    popd
fi

if [ -e "$(readlink 'latest.bin')" ]; then
  rm "$(readlink 'latest.bin')"
fi

# EXCLUDE PACKAGES
PKG=" -ip6tables"
PKG+=" -kmod-ip6tables"
PKG+=" -kmod-ipv6"
PKG+=" -kmod-ppoe"
PKG+=" -kmod-ppp"
PKG+=" -kmod-pppox"
PKG+=" -libip6tc"
PKG+=" -libip6tc"
PKG+=" -odhcp6c"
PKG+=" -ppp"
PKG+=" -ppp-mod-pppoe"

# INCLUDE PACKAGES
PKG+=" block-mount"
PKG+=" e2fsprogs"
PKG+=" fdisk"
PKG+=" kmod-fs-ext4"
PKG+=" kmod-scsi-core"
PKG+=" kmod-scsi-generic"
PKG+=" kmod-usb-core"
PKG+=" kmod-usb-net-cdc-ether"
PKG+=" kmod-usb-ohci"
PKG+=" kmod-usb-storage"
PKG+=" kmod-usb-uhci"
PKG+=" kmod-usb2"
PKG+=" partx-utils"
PKG+=" uhttpd"
#P="$P usb-modeswitch"

echo ${IMGBUILDER_DIR}
pushd ${IMGBUILDER_DIR}
make image PROFILE=${TARGET_DEVICE} PACKAGES="$PKG" FILES=$ROOT/files
popd

IMAGE_NAME=lede-$RELEASE-$TARGET_ARCHITECTURE-$TARGET_VARIANT-${TARGET_DEVICE}-squashfs-factory.bin

# echo "----------------------------------"
ls -al ${IMGBUILDER_DIR}/bin/targets/${TARGET_ARCHITECTURE}/${TARGET_VARIANT}/$IMAGE_NAME

ln -s ${IMGBUILDER_DIR}/bin/targets/${TARGET_ARCHITECTURE}/${TARGET_VARIANT}/$IMAGE_NAME latest.bin

pwd

# lede-17.01.4-ar71xx-generic-tl-wr710n-v1-squashfs-factory.bin

# pushd bin/targets/${TARGET_ARCHITECTURE}/
# ln -s ../../packages .
# popd


# pushd image-generator
# make image PROFILE=TLMR3020 PACKAGES="$PKG" FILES=files/
# popd

# ls -al "$(readlink 'latest.bin')"
