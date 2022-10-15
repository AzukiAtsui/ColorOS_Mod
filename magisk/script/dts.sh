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

MODDIR=$(cd "${0%/*}/..";pwd)
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
org_dtbo=$MODDIR/原版-$dtbo_nm
new_dtbo=$MODDIR/new-$dtbo_nm
damCM=/data/adb/modules/coloros_mod
bk_dtbo=$damCM/原版-$dtbo_nm
bkn_dtbo=$damCM/new-$dtbo_nm
DTSTMP=$MODDIR/dts
[[ -d $DTSTMP ]] || mkdir -p $DTSTMP
source /data/adb/magisk/util_functions.sh

chkSlot(){
	SLOT=`grep_cmdline androidboot.slot_suffix`
	if [ -z $SLOT ];then
		SLOT=`grep_cmdline androidboot.slot`
		[ -z $SLOT ] || SLOT=_${SLOT}
	fi
}

dtboDump(){
if [ -f $1 ];then
	mkdtimg dump $1 -b $2
else
	echo "缺少原版镜像$1，尝试自动提取"
	chkSlot
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
echo "Lines $i"

j=0
while ((j < i))
do
	val1="${acc[$j]}"
	((j++))
	val2="${acc[$j]}"
	# patch1=`grep -l -r -n "$val1" $DTSTMP`
	for patch1 in `grep -l -r -n "$(echo $val1 | sed 's/=.*/=/')" $DTSTMP`;do
	[ -z $patch1 ] && continue
	echo -e "\n匹配修改${patch1##*/}的$val1"
	sed -i "s/$val1/$val2/g" $patch1
		if [ $? -ne 0 ];then
			echo "line $j failed!"
			exit 8
		else
			echo "line $j succeed! "
		fi
	done
	((j++))
done
}

dts2dtb(){
for i in $(find $DTSTMP -name "$1.*")
do
	j=$(echo $i | sed 's/'$1'/'$2'/')
	dtc -I dts -O dtb -@ $i -o $j >/dev/null 2>&1
done
}

mkdtimgF(){
mkdtimg create $1 --page_size=4096 $(find $DTSTMP -name "$2.*")
}

flashDtbo(){
	chkSlot
	dd if=$new_dtbo of=/dev/block/by-name/dtbo$SLOT
	BOOTIMAGE="/dev/block/by-name/boot$SLOT"
	install_magisk >/dev/null 2>&1
	# AVB_flag=3 bash $MODSCRIPT/avb.sh ;# cause fingerprint bug in v1.1.4 ~ v1.1.6
	echo 1 >$dtbo_sign
	exit 0
}

main(){
dtboDump $org_dtbo dtbA
dtb2dts dtbA dtsA
configReplace 2>&1
dts2dtb dtsA dtbB
mkdtimgF $new_dtbo dtbB
if [ $? -eq 0 ];then
	flashDtbo
else
	echo "失败记录"
	echo 4 >$dtbo_sign
fi
}

bk2up(){
[ -f $bk_dtbo ] && cp -f $bk_dtbo $org_dtbo
[ -f $bkn_dtbo ] && cp -f $bkn_dtbo $new_dtbo
if [ ! -f $bk_dtbo ];then
	echo 未找到当前版本的dtbo，也许是更新系统了？即将提取dtbo并修改。
	main
fi
}

case $(cat $dtbo_sign) in
	1) bk2up;;
	2)
		echo "还原备份的dtbo"
		chkSlot
		if [ -z $SLOT ];then
			dd if=$org_dtbo of=/dev/block/by-name/dtbo_a
			dd if=$org_dtbo of=/dev/block/by-name/dtbo_b
		else
			dd if=$org_dtbo of=/dev/block/by-name/dtbo
		fi
		BOOTIMAGE="/dev/block/by-name/boot$SLOT"
		install_magisk >/dev/null 2>&1
		# AVB_flag=3 bash $MODSCRIPT/avb.sh
		;;
	3) bk2up;;
	*) main;;
esac
exit 5

