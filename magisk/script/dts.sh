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

MODDIR=${ColorOS_MOD_INSTALL_PATH:-$(cd ${0%/*/*};pwd)}
MODBIN=$MODDIR/bin
MODCONFIG=$MODDIR/config
MODSCRIPT=$MODDIR/script
MODSIGN=$MODDIR/sign
dtbo_sign=$MODSIGN/dtbo
verid=$(getprop ro.build.display.id)
id_config="$MODCONFIG/dts"
[[ ! -f $id_config && $(cat $dtbo_sign) -ne 2 ]] && exit 14
chmod +x $(find $MODBIN)
export PATH="$MODBIN":"$PATH"
[[ -z $($MODBIN/dtc -v | grep 'Version') ]] && exit 13
[[ -z $($MODBIN/mkdtimg help all | grep 'cfg_create') ]] && exit 12
[[ -z $($MODBIN/bash --version | grep 'version') ]] && exit 11
dtbo_nm=dtbo-${verid}.img
org_dtbo=$MODDIR/origin-$dtbo_nm
new_dtbo=$MODDIR/new-$dtbo_nm
damCM=/data/adb/modules/coloros_mod
bk_dtbo=$damCM/origin-$dtbo_nm
bkn_dtbo=$damCM/new-$dtbo_nm
DTSTMP=$MODDIR/dts
[[ -d $DTSTMP ]] || mkdir -p $DTSTMP
source /data/adb/magisk/util_functions.sh

SLOT=`grep_cmdline androidboot.slot_suffix`
if [ -z $SLOT ]; then
	SLOT=`grep_cmdline androidboot.slot`
	[ -z $SLOT ] || SLOT=_${SLOT}
fi

disavb() {
	AVB_flag=3 bash $MODSCRIPT/avb.sh
	BOOTIMAGE="/dev/block/by-name/boot$SLOT"
	install_magisk >/dev/null 2>&1
}

dtboDump(){
	if [ -f $1 ];then
		mkdtimg dump $1 -b $2
	else
		echo "Not found origin dtbo.img $1，try extract dtbo$SLOT"
		dd if=/dev/block/by-name/dtbo$SLOT of=$1
		mkdtimg dump $1 -b $2
	fi
}

dtb2dts(){
	for i in $(find . -name "$1.*")
	do
		j=$(echo $i | sed 's/'$1'/'$2'/')
		dtc -I dtb -O dts -@ $i -o $j >/dev/null 2>&1
		mv -f $i $DTSTMP
		mv -f $j $DTSTMP
	done
}

configReplace(){
	i=0
	acc=()
	while read line
	do
		acc[$i]="$line"
		let i++
	done <$id_config

	j=0
	while ((j < i))
	do
		val1="${acc[$j]}"
		((j++))
		val2="${acc[$j]}"
		((j++))
		val3="${acc[$j]}"
		# patch1=`grep -l -r -n "$val1" $DTSTMP`
		# [ -z "$patch1" ] && continue
		echo -e "\n\n##########################################"
		echo "# At filed $(($((j + 1))/3)) : $val1 "
		echo "##########################################"
		for patch1 in `grep -l -r -n "$val1" $DTSTMP`; do
			echo -e "\n## Editing ${patch1##*/}..."
			function match1() { sed -n "/$val1\ $val2/p" $patch1 | sed 's/^[[:space:]]*//' ; }
			if [ -z "`match1`" ]; then
				echo "! UNMATCHED PATTERN1 : $val2"
				continue
			fi

			echo "#### Found :"
			match1
			echo ""
			echo "#### Modify <value> to $val3..."
			sed -i "/$val1/s/$val2/$val3/g" $patch1
			if [ $? -ne 0 ]; then
				echo "✘ FAILED."
				exit 8
			else
				echo "✔ SUCCEED."
			fi
		done
		((j++))
	done
}

dts2dtb(){
	for i in $(find $DTSTMP -name "$1.*"); do
		j=$(echo $i | sed 's/'$1'/'$2'/')
		dtc -I dts -O dtb -@ $i -o $j >/dev/null 2>&1
	done
}

mkdtimgF(){
	mkdtimg create $1 --page_size=4096 $(find $DTSTMP -name "$2.*")
}

flashDtbo(){
	dd if=$new_dtbo of=/dev/block/by-name/dtbo$SLOT
	disavb
	echo 1 >$dtbo_sign
	exit 0
}

main(){
	dtboDump $org_dtbo dtbA
	dtb2dts dtbA dtsA
	configReplace 2>&1
	dts2dtb dtsA dtbB
	mkdtimgF $new_dtbo dtbB
	if [ $? -eq 0 ]; then
		flashDtbo
	else
		exit 4
	fi
}

bk2up(){
	[ -f $bk_dtbo ] && cp -f $bk_dtbo $org_dtbo
	[ -f $bkn_dtbo ] && cp -f $bkn_dtbo $new_dtbo
	if [ ! -f $bk_dtbo ];then
		echo "Not found origin dtbo.img of the $verid right now."
		main
	fi
}

case $(cat $dtbo_sign) in
	1) bk2up;;
	2)
		echo "还原备份的dtbo"
		if [ -z $SLOT ]; then
			dd if=$org_dtbo of=/dev/block/by-name/dtbo
		else
			dd if=$org_dtbo of=/dev/block/by-name/dtbo_a
			dd if=$org_dtbo of=/dev/block/by-name/dtbo_b
		fi
		disavb
		;;
	3) bk2up;;
	*) main;;
esac
exit 5

