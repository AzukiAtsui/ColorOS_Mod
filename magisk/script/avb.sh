#!/bin/sh
#
# This file is part of ColorOS_Mod.
# Copyright 2022 AzukiAtsui
# Core codes in this file was writed by Han | 情非得已c , see /app/src/main/assets/usr/kr-script/Block_Device_Name.sh and /app/src/main/assets/usr/kr-script/Forbid_AVB.sh in <https://github.com/liuran001/GJZS>.
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

# To use this script, set environment variable AVB_flag to [0-3].
# AVB_flag=0 ;# enable AVB;
# AVB_flag=1 ;# diable dm-verity (disable-verity);
# AVB_flag=2 ;# diable boot verification (diable-verification);
# AVB_flag=3 ;# disable both (same effect to `fastboot --slot all --disable-verity --disable-verification flash vbmeta vbmeta.img`).
# Example: `AVB_flag=3 bash avb.sh`
#
# For more info of AVB (Android Verified Boot), see <https://source.android.com/docs/security/features/verifiedboot/avb>

# For more info of magisk busybox, see <https://topjohnwu.github.io/Magisk/guides.html#busybox>
bb=/data/adb/magisk/busybox

abort() {
	echo "$1"
	exit 1
}

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

check_vbmeta_slot() {
	if [ -z $SLOT ];then
		echo /dev/block/by-name/vbmeta
	else
		echo /dev/block/by-name/vbmeta_a
		echo /dev/block/by-name/vbmeta_b
	fi
}

BlockByName() {
	a=0
	b=(`find /dev/block/* -prune`)
	for i in ${b[@]}; do a=$((a+1)); done
	find /dev/block -type l | while read o
	do
		[[ -d "$o" ]] && continue
		c=`basename "$o"`
		echo ${b[@]} | grep -q "$c" && continue
		echo $c
	done | sort -u | while read Row
	do
		find /dev/block -name $Row | head -n 1
			# BLOCK2=`readlink -e $BLOCK`
		# size=`$bb blockdev --getsize64 $BLOCK`
		# if [[ $size -ge 1073741824 ]];then bz=$(($size / 1073741824)) GB
		# elif [[ $size -ge 1048576 ]];then bz=$(($size / 1048576)) MB
		# elif [[ $size -ge 1024 ]];then bz=$(($size / 1024)) KB
		# elif [[ $size -le 1024 ]];then "bz=${size} B";fi
		# echo "$BLOCK|$Row <Size ：$bz>"
	done
}

vblist() {
	case `echo $SHELL | sed 's/.*\///g'` in
		bash) BlockByName | grep '/vbmeta'
			# `BlockByName | grep '/vbmeta' | sed 's/|.*//g'`
			;;
		*) check_vbmeta_slot ;;
	esac
}

AVB_Switch() {
	[[ -z $AVB_flag ]] && abort "ERROR! Variable AVB_flag Not Set."

	while read vb
	do
		echo ""
		echo "*******************"
		echo " Modifing ${vb##*/}"
		echo "*******************"
		jz=`$bb od -w16 -An -tx1 "$vb" | grep -i -B 2 '61 76 62 74 6f 6f 6c 20' | tr -d '[:space:]' | grep -E -oi '0000000000000000000000..00000000617662746f6f6c20'`
		if [[ -z "$jz" ]];then
			echo "Jeez! field 'avbtool ' Not Found."
			echo "$vb BROKEN or NOT VBMETA???"
			continue
		fi
	
		echo "# Checking AVB flag state:"
		case $jz in
			00000000000000000000000300000000617662746f6f6c20) echo "3, AVB Disabled." ;;
			00000000000000000000000200000000617662746f6f6c20) echo "2, Boot Verification Disabled." ;;
			00000000000000000000000100000000617662746f6f6c20) echo "1, Dm-verity Disabled." ;;
			00000000000000000000000000000000617662746f6f6c20) echo "0, AVB Enabled." ;;
	esac

		echo ""
		echo "# Setting AVB flag to $AVB_flag..."
		case $AVB_flag in
			3) echo "AVB Disabling..." ;;
			2) echo "Boot Verification Disabling..." ;;
			1) echo "Dm-verity Disabling..." ;;
			0) echo "AVB Enabling..." ;;
		esac
		/data/adb/magisk/magiskboot hexpatch "$vb" $jz 00000000000000000000000${AVB_flag}00000000617662746F6F6C20 &>/dev/null
		case $? in
			0) echo "Succeed. :-)" ;;
			*) abort "FAILED! Patch $vb hex data failed !!! :-(" ;;
		esac
	done <<eof
	`vblist`
eof
}

AVB_Switch

