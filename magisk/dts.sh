#
# This file is part of ColorOS_Mod.
# Copyright (C) 2022  AzukiAtsui
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

MODDIR=${0%/*}
# verid=$(getprop ro.build.display.id) # 版本号
# realmeGTNeo2domestic's model_nm=RMX3370
model_nm=$(getprop ro.product.vendor.model)
[ -z $model_nm ] && exit 404
id_config="$MODDIR/dts_configs/${model_nm}.txt"
[ -f $id_config ] || exit 14
[ -f $MODDIR/bin/dtc ] || exit 13
[ -f $MODDIR/bin/mkdtimg ] || exit 12
org_dtbo=$MODDIR/${model_nm}-原版-dtbo.img
new_dtbo=$MODDIR/${model_nm}-new-dtbo.img
damCM=/data/adb/modules/coloros_mod
bk_dtbo=$damCM/${model_nm}-原版-dtbo.img
bkn_dtbo=$damCM/${model_nm}-new-dtbo.img
dtbo_sign=$MODDIR/dtbo_sign
DTSTMP=$MODDIR/dts
[[ -d $DTSTMP ]] || mkdir -p $DTSTMP
export PATH="$MODDIR/bin":"$PATH"
. /data/adb/magisk/util_functions.sh

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
echo "$id_config 共 $i 行"

j=0
while ((j < i))
do
	val1="${acc[$j]}"
	((j++))
	val2=${acc[$j]}
	# patch1=`grep -l -r -n "$val1" $DTSTMP`
	for patch1 in `grep -l -r -n "$val1" $DTSTMP`;do
	[ -z $patch1 ] && continue
	echo -e "\n开始修改${patch1##*/} :\n$val1"
	sed -i "s/${val1}/${val2}/g" $patch1
		if [ $? -ne 0 ];then
			echo "line $(( $j )) failed!"
		else
			echo "line $(( $j )) succeed! "
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

bk2up(){
[ -f $bk_dtbo ] && cp -f $bk_dtbo $org_dtbo
[ -f $bkn_dtbo ] && cp -f $bkn_dtbo $new_dtbo
}

main(){
dtboDump $org_dtbo dtbA
dtb2dts dtbA dtsA
configReplace 2>&1
dts2dtb dtsA dtbB
mkdtimgF $new_dtbo dtbB
}

case $(cat $dtbo_sign) in
	1)
		bk2up
		;;
	2)
		echo "还原备份的dtbo"
		chkSlot
		if [ -z $SLOT ];then
			dd if=$org_dtbo of=/dev/block/by-name/dtbo_a
			dd if=$org_dtbo of=/dev/block/by-name/dtbo_b
		else
			dd if=/$org_dtbo of=/dev/block/by-name/dtbo
		fi
		;;
	3)
		bk2up
		;;
	*)
		main
		if [ $? -eq 0 ];then
			chkSlot
			dd if=$new_dtbo of=/dev/block/by-name/dtbo$SLOT
			BOOTIMAGE="/dev/block/by-name/boot$SLOT"
			install_magisk >/dev/null 2>&1
			echo 1 >$dtbo_sign
			exit 0
		else
			echo "失败记录"
			echo 4 >$dtbo_sign
		fi
		;;
esac
exit 5

