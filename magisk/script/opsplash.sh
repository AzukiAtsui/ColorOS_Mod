#!/bin/sh
#
# This file is part of ColorOS_Mod.
# Copyright 2022 affggh and AzukiAtsui
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

MODDIR=${ColorOS_MOD_INSTALL_PATH:-$(cd ${0%/*/*};pwd)}
MODBIN=$MODDIR/bin
MODCONFIG=$MODDIR/config
MODSCRIPT=$MODDIR/script
MODSIGN=$MODDIR/sign

if [ "`cat /sys/devices/soc0/family`" != "Snapdragon" ]; then
	echo "E! 不支持非高通骁龙设备！"
	exit 16
fi

splash_sign=$MODSIGN/splash
verid=$(getprop ro.build.display.id)
chmod +x $(find $MODBIN)
export PATH="$MODBIN:$PATH"
[ -z "$(opsplash | grep 'unpack')" ] && exit 15
[ -z "$($MODBIN/bash --version | grep 'version')" ] && exit 11
damCM=/data/adb/modules/coloros_mod
SPLASHTMP=$MODDIR/splash
[[ -d $SPLASHTMP ]] || mkdir -p $SPLASHTMP
# default boot screen, or set environment variable WHICH_SCREEN.
WHICH_SCREEN=${WHICH_SCREEN:-boot.bmp}
PIC=$MODCONFIG/$WHICH_SCREEN

chkbmp() {
	f="$1"
	magic=`xxd -l 2 -p "$f"`
	recordsz=`od -A none -j 2 -N 4 -t d4 "$f" | tr -d " "`
	filesize=`stat -c %s "$f"`
	headersz=`od -A none -j 10 -N 1 -d "$f" | tr -d " "`
	# check header magic
	if [[ ! 424d == $magic ]]; then echo "E! Invalid bmp header!" >&2; return 1; fi
	# check file size
	if [[ ! $recordsz == $filesize ]]; then echo "E! File size not match with header!" >&2; return 1; fi
	# check header size/version
	if [[ ! $headersz == 54 ]]; then echo "E! Header version not bmp3!" >&2; return 1; fi
	return 0;
}

if [ -f $PIC ]; then
	chkbmp "$PIC"
	if [ "$?" -ne "0" ]; then
		echo "E! Invalid bmp image file"
		exit 10
	fi
else
	echo  "E! File $PIC not found."
	exit 9
fi

grep_cmdline() {
	local REGEX="s/^$1=//p"
	{ echo $(cat /proc/cmdline)$(sed -e 's/[^"]//g' -e 's/""//g' /proc/cmdline) | xargs -n 1; \
		sed -e 's/ = /=/g' -e 's/, /,/g' -e 's/"//g' /proc/bootconfig; \
	} 2>/dev/null | sed -n "$REGEX"
}

SLOT=`grep_cmdline androidboot.slot_suffix`
if [ -z $SLOT ]; then
	SLOT=`grep_cmdline androidboot.slot`
	[ -z $SLOT ] || SLOT=_${SLOT}
fi
[ -z $SLOT ] || sa="_a"

if [ "`ls /dev/block/by-name | grep splash$SLOT`" == "splash$SLOT" ];then bdn=splash
elif [ "`ls /dev/block/by-name | grep logo$SLOT`" == "logo$SLOT" ];then
	# OnePlus 8 and later series running ColorOS.
	[ -z "`getprop ro.build.version.oplusrom`" ] || exit 7
	bdn=logo
else
	exit 6
fi

bd=$bdn$sa
org_splash=$MODDIR/origin-${verid}-$bd.img
new_splash=$MODDIR/new-${verid}-$bd.img
bk_splash=$damCM/origin-${verid}-$bd.img
bkn_splash=$damCM/new-${verid}-$bd.img

ckScn(){
	# printf "- 选择替换的页面为："
	case $WHICH_SCREEN in
		fastboot.bmp) echo "FASTBOOT启动页";;
		verify.bmp) echo "系统文件被破坏 (system verify failed)";;
		boot_charger_low_battery3.bmp) echo "低电量 (low battery)";;
		boot.bmp) echo "开机第一屏 (standard 1st startup screen)";;
		boot_without_android.bmp) echo "不带安卓的开机 (boot_without_android)";;
		perversion.bmp) echo "未挂载my_分区时的android开机 (unmouting my_* slots (android) boot screen)";;
		engineering.bmp) echo "工程测试机开机 (engineering device boot screen)";;
		ExpSellLogo.bmp) echo "外销设备开机 (Export device boot screen)";;
		cmcctest.bmp) echo "中国移动开机 (CMCC boot screen)";;
		cmcc_with_android.bmp) echo "中国移动带安卓开机 (CMCC with Android boot screen)";;
		Telstra.bmp) echo "澳洲电信开机 (Telstra boot screen)";;
		realme.bmp) echo "realme";;
		CTSI31.bmp) echo "八一 (EGHIT ONE)";;
		YunLuTong.bmp) echo "云路通 (YunLuTong)";;
		GreenUmbrella.bmp) echo "小绿伞 (GreenUmbrella)";;
		perfect.bmp) echo "完美中国 (Perfect CN)";;
		foshanGov.bmp) echo "佛山政 (foshan Gov)";;
		CTSIPOLICE.bmp) echo "警察 (CTSIPOLICE)";;
		black.bmp) echo "纯黑 (total black)";;
		test.bmp) echo "2K TEST";;
		rf.bmp) echo "rf 测试 (rf test)";;
		at.bmp) echo "AT 电流测试 (AT electric current test)";;
		wlan.bmp) echo "WLAN 测试 (wlan test)";;
		*) echo "Unkwon $WHICH_SCREEN";;
	esac
}

main() {
	if [ ! -f $org_splash ];then
		echo "- 备份$bd 分区镜像..." >&2
		dd if="/dev/block/by-name/$bd" of="$org_splash"
	fi
	echo "- 开始编辑$bd 镜像..."
	cd $SPLASHTMP
	opsplash unpack -i $org_splash -o "$SPLASHTMP/pic" >/dev/null 2>&1
		if [ "$?" -ne "0" ]; then
			echo "E! unpack failed."
			exit 3
		fi
	# echo "- 替换$(ckScn) 图像..."
	cp -f "$PIC" "$SPLASHTMP/pic/${PIC##*/}"
	opsplash repack -i $org_splash -o "$new_splash" >/dev/null 2>&1
		if [ "$?" -ne "0" ]; then
			echo "E! repack failed."
			exit 2
		fi
	# echo "- 清理临时文件..."
	rm -rf "$SPLASHTMP"

	AVB_flag=3 bash $MODSCRIPT/avb.sh >&2
	echo "- 刷写 $bd" >&2
	dd if="$new_splash" of="/dev/block/by-name/$bd"
		if [ "$?" -eq "0" ]; then
			echo 1 >$splash_sign
			exit 0
		fi
}

bk2up(){
	echo "- 复制备份到更新目录"
	[ -f $bk_splash ] && cp -f $bk_splash $org_splash
	[ -f $bkn_splash ] && cp -f $bkn_splash $new_splash
	if [ ! -f $bk_splash ];then
		echo "I! Not found origin splash.img of the $verid right now."
		main
	fi
}

case $(cat $MODSIGN/splash) in
	1) bk2up;;
	2) # recovery splash
		dd if="$bk_splash" of="/dev/block/by-name/$bd"
		;;
	3) bk2up;;
	*) main;;
esac
exit 255

