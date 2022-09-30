#
# This file is part of ColorOS_Mod.
# Copyright (C) 2022  AzukiAtsui
# Codes in this file was mainly writed by Han | 情非得已c , used in 搞机助手. see /app/src/main/assets/usr/kr-script/Block_Device_Name.sh and /app/src/main/assets/usr/kr-script/Forbid_AVB.sh in <https://github.com/liuran001/GJZS>
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

#
# To use this script, set environment variable AVB_flag to [0-3].
# 0 to enable AVB;
# 1 to diable dm-verity (disable-verity);
# 2 to diable boot verification (diable-verification);
# 3 to disable both (similar to `fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img`).
# Example: `AVB_flag=3 . avb.sh`
#
# For more info of AVB (Android Verified Boot), see <https://source.android.com/docs/security/features/verifiedboot/avb>
#


abort() {
echo -e "$1" 1>&2
exit 1
}

# For more info of magisk busybox, see <https://topjohnwu.github.io/Magisk/guides.html#busybox>
alias AWK="/data/adb/magisk/busybox awk"
alias BLOCKDEV="/data/adb/magisk/busybox blockdev"

BlockByName() {
a=0
b=(`ls /dev/block/`)
for i in ${b[@]}
do
	[[ -d /dev/block/$i ]] && unset b[$a]
	a=$((a+1))
done
find /dev/block -type l | while read o
do
	[[ -d "$o" ]] && continue
	c=`basename "$o"`
	echo ${b[@]} | grep -q "$c" && continue
	echo $c
done | sort -u | while read Row
do
		BLOCK=`find /dev/block -name $Row | head -n 1`
		# BLOCK2=`readlink -e $BLOCK`
	size=`BLOCKDEV --getsize64 $BLOCK`
	if [[ $size -ge 1073741824 ]]; then
		File_Type=`AWK "BEGIN{print $size/1073741824}"`G
	elif [[ $size -ge 1048576 ]]; then
		File_Type=`AWK "BEGIN{print $size/1048576}"`MB
	elif [[ $size -ge 1024 ]]; then
		File_Type=`AWK "BEGIN{print $size/1024}"`kb
	elif [[ $size -le 1024 ]]; then
		File_Type=${size}b
	fi
	echo "$BLOCK|$Row 「大小 (Block size)：$File_Type」"
done
}

[[ -z $AVB_flag ]] && abort "ERROR! Variable AVB_flag has not been set."
echo AVB-$AVB_flag
while read line
do
	[[ -z `strings $line` ]] && continue
	typeset -u jz
	jz=`busybox od -w16 -An -tx1 "$line" | grep -i -B 2 '61 76 62 74 6f 6f 6c 20' | tr -d '[:space:]' | grep -E -oi '0000000000000000000000..00000000617662746f6f6c20'`
	[[ -z "$jz" ]] && continue
	/data/adb/magisk/magiskboot hexpatch "$line" $jz 00000000000000000000000${AVB_flag}00000000617662746F6F6C20 &>/dev/null || abort "FAILED! Patch vbmeta hex data failed !!!"
done <<eof
`BlockByName | grep '/vbmeta' | sed 's/|.*//g'`
eof
echo Done.

