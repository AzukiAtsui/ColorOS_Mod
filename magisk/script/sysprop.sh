#!/bin/sh
#
# This file is part of ColorOS_Mod.
# Copyright 2022 AzukiAtsui
#
# ColorOS_Mod is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ColorOS_Mod is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ColorOS_Mod.  If not, see <https://www.gnu.org/licenses/>.
#

[ -z "$API" ] && API=$(getprop ro.build.version.sdk)
[ -z "$ABI" ] && ABI=$(getprop ro.product.cpu.abi)
if [ "$ABI" = "x86" ]; then
	ARCH=x86;ABI32=x86;IS64BIT=false
elif [ "$ABI" = "arm64-v8a" ]; then
	ARCH=arm64;ABI32=armeabi-v7a;IS64BIT=true
elif [ "$ABI" = "x86_64" ]; then
	ARCH=x64;ABI32=x86;IS64BIT=true
else
	ARCH=arm;ABI=armeabi-v7a;ABI32=armeabi-v7a;IS64BIT=false
fi

nvid=`getprop ro.build.oplus_nv_id`
chkNvid(){
case $nvid in
	10010111) echo CN 中国 China;;
	00011010) echo TW 中国台湾省 Taiwan;;
	00110111) echo RU 俄罗斯 Russia;;
	01000100) echo GDPR 欧盟 EU;;
	10001101) echo GDPR 欧洲 Europe;;
	00011011) echo IN 印度 India;;
	00110011) echo ID 印度尼西亚 Indonesia;;
	00111000) echo MY 马来西亚 Malaysia;;
	00111001) echo TH 泰国 Thailand;;
	00111110) echo PH 菲律宾 Philippines;;
	10000011) echo SA 沙特阿拉伯 Saudi Arabia;;
	10011010) echo LATAM 拉丁美洲 Latin America;;
	10011110) echo BR 巴西 Brazil;;
	10100110) echo MEA 中东和非洲 The Middle East and Africa;;
	*) echo "设备的国家/地区代码 (NV (carrier) identifier) = $nvid";;
esac
}

[[ $(date "+%H%M") -lt 600 || $(date "+%H%M") -gt 2200 ]] && echo "当前系统时间 $(date "+%Y-%m-%d %H:%M:%S")，应该休息！"
product_model=`getprop ro.product.model` ;# value of ro.product.name is diffrent to ro.product.model in ColorOS for OnePlus; but they are same in realmeUI.
ota_version=`getprop ro.build.version.ota`
rui_version=`getprop ro.build.version.realmeui` ;# | sed 's/V//' | sed 's/\.0//'
product_id=`getprop ro.commonsoft.ota`
CODENAME=`cat /sys/firmware/devicetree/base/model | sed -n 's/.*[A-Z0-9][ ,]//;p'`
project_name=`getprop ro.separate.soft` ;# ro.boot.prjname
product_brand=`getprop ro.product.vendor.brand`
market_enname=`getprop ro.vendor.oplus.market.enname`
[ -z "$market_enname" ] && market_enname=`getprop ro.oppo.market.enname`
SOC=`getprop ro.soc.model`
[ -z "$SOC" ] && SOC=`getprop ro.build.device_family | sed 's/^OP//'`
COSV=`getprop ro.build.version.oplusrom`
[ -z "$COSV" ] && COSV=`getprop ro.build.version.opporom`

echo ""
echo "- ** 设备信息 (DEVICE INFO) **"
echo "- 品牌 (Brand) : $product_brand"
echo "- 品名 (Product Name) : `getprop ro.product.name`"
echo "- 型号 (Model) : $product_model"
echo "- 市场名 (Market Name) : `getprop ro.vendor.oplus.market.name`"
[ -z "$market_enname" ] || echo "- Market English Name : $market_enname"
echo "- 设备码 (Device ID) : $product_id"
echo "- 项目 (Project Name) : $project_name"
echo "- 代号 (Codename) : $CODENAME"
echo "- 地区 (Locale) : `getprop ro.product.locale`"
echo "- 国家/区域 (Nation/Region) : `chkNvid`"
echo "- 版本号 (Build number) : `getprop ro.build.display.id`"
echo "- OTA版本 (OTA Version) : $ota_version"
echo "- ColorOS 版本 (ColorOS Version) : $COSV"
[ -z $rui_version ] || echo "- realmeUI 版本 (realmeUI Version) : $rui_version"
echo "- 基线版本 (Baseline) : `getprop ro.build.version.incremental`"
echo "- Android 版本 (Android Version) : `getprop ro.build.version.release`"
echo "- API level : $API"
echo "- SOC 型号 (SOC Model): $SOC"
echo "- CPU 架构 (CPU architecture) : $ARCH"
echo "- 内核版本 (Kernel Version) : `uname -a`"
echo "- 运存大小 (RAM/memory Info) : `free -m|grep "Mem"|awk '{print $2}'` MB ; 已用 (Uesd) : `free -m|grep "Mem"|awk '{print $3}'` MB ; 剩余 (Availale) : $((`free -m|grep "Mem"|awk '{print $2}'`-`free -m|grep "Mem"|awk '{print $3}'`)) MB"
echo "- Swap大小 (Swap Info) : `free -m|grep "Swap"|awk '{print $2}'` MB ; 已用 (Uesd) : `free -m|grep "Swap"|awk '{print $3}'` MB ; 剩余 (Availale) : `free -m|grep "Swap"|awk '{print $4}'` MB"
echo ""

