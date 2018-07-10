# OpenWrt / LEDE Experiments

## Install
1. clone this repo to a linux install with build essentials
2. run the script:
```
./build.sh
```
3. download or copy the generated .bin file and flash your OpenWrt/LEDE device
```
cd /tmp && wget http://vps.companje.nl/openwrt-experiments/bin/latest.bin && sysupgrade -v -n latest.bin
```
