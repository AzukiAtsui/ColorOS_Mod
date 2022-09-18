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
damCM=/data/adb/modules/coloros_mod
. /data/adb/magisk/util_functions.sh
dtb_nm=dtbA
dts_nm=dtsA
n_dtb_nm=dtbB
# verid=$(getprop ro.build.display.id) # 版本号
# realmeGTNeo2domestic's model_nm=RMX3370
model_nm=$(getprop ro.product.vendor.model)
[ -z $model_nm ] && exit 404
id_config="$MODDIR/dts_configs/${model_nm}.txt"
org_dtbo=$MODDIR/${model_nm}-原版-dtbo.img
new_dtbo=$MODDIR/${model_nm}-new-dtbo.img
bk_dtbo=$damCM/${model_nm}-原版-dtbo.img
bkn_dtbo=$damCM/${model_nm}-new-dtbo.img
dtbo_sign=$MODDIR/dtbo_sign

chkSlot(){
	SLOT=`grep_cmdline androidboot.slot_suffix`
	if [ -z $SLOT ]; then
		SLOT=`grep_cmdline androidboot.slot`
		[ -z $SLOT ] || SLOT=_${SLOT}
	fi
}

dtboBak(){
if [ -f '$org_dtbo' ];then
	$MODDIR/bin/mkdtimg dump $org_dtbo -b $dtb_nm >/dev/null 2>&1
else
	echo "缺少原版镜像$org_dtbo，尝试自动提取"

	chkSlot
	dd if=/dev/block/by-name/dtbo$SLOT of=$org_dtbo
	# cp $org_dtbo $MODPATH/$org_dtbo
	
	$MODDIR/bin/mkdtimg dump $org_dtbo -b $dtb_nm >/dev/null 2>&1
fi
}

dtb2dts(){
for i in $(find . -name "$dtb_nm.*")
do
	j=$(echo $i | sed 's/'$dtb_nm'/'$dts_nm'/')
	$MODDIR/bin/dtc -I dtb -O dts -@ $i -o $j >/dev/null 2>&1
	[[ -d ./dts ]] || mkdir -p ./dts
	mv -f $dts_nm.* ./dts
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
echo $i

j=0
while ((j < i))
do
	val1="${acc[$j]}"
	((j++))
	val2=${acc[$j]}
	patch1=`grep -l -r -n "$val1" ./dts` >/dev/null 2>&1
	[ -z $patch1 ] && continue
	echo -e "\n开始修改$val1 :\n$patch1"
	sed -i "s/${val1}/${val2}/g" $patch1 >/dev/null 2>&1
		if [ $? -ne 0 ];then
			echo "failed! $id_config 第 $(( $j )) 行修改失败"
		else
			echo "line $(( $j )) succeed! "
		fi
	((j++))
done
}

dts2dtb(){
for i in $(find ./dts -name "$dts_nm.*")
do
	j=$(echo $i | sed 's/'$dts_nm'/'$n_dtb_nm'/')
	$MODDIR/bin/dtc -I dts -O dtb -@ $i -o $j >/dev/null 2>&1
done
}

mkdtimgF(){
$MODDIR/bin/mkdtimg create $new_dtbo --page_size=4096 $(find ./dts -name "$n_dtb_nm.*") >/dev/null 2>&1
}

bk2up(){
[ -f $bk_dtbo ] && mv -f $bk_dtbo $org_dtbo
[ -f $bkn_dtbo ] && mv -f $bkn_dtbo $new_dtbo
}

main(){
dtboBak

dtb2dts
if [ -f $id_config ];then
	configReplace
else
	echo 22 >$dtbo_sign
	exit 14
fi
dts2dtb
mkdtimgF
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
		if [ -f $MODDIR/bin/dtc ];then
			chmod +x $MODDIR/bin/dtc && echo "已赋dtc可执行权限"
		else
			exit 13
		fi
			if [ -f $MODDIR/bin/mkdtimg ];then
				chmod +x $MODDIR/bin/mkdtimg && echo "已赋mkdtimg可执行权限"
			else
				exit 12
			fi
		main
		if [ $? -eq 0 ];then
			chkSlot
			dd if=$new_dtbo of=/dev/block/by-name/dtbo$SLOT
			BOOTIMAGE="/dev/block/by-name/boot$SLOT"
			install_magisk
			echo 1 >$dtbo_sign
			exit 0
		else
			echo "失败记录"
			echo 4 >$dtbo_sign
		fi
		;;
esac
exit 5

