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

MODDIR=${0%/*}
MODBIN=$MODDIR/bin
MODCONFIG=$MODDIR/config
MODSCRIPT=$MODDIR/script
MODSIGN=$MODDIR/sign
swapfile_path=/data/nandswap/swapfile
hybridswap_sign=$MODSIGN/hybridswap

toolkit() {
if [[ -f /system/bin/swapon ]];then
	alias swapon="/system/bin/swapon"
	alias swapoff="/system/bin/swapoff"
	alias mkswap="/system/bin/mkswap"
elif [[ -f /vendor/bin/swapon ]];then
	alias swapon="/vendor/bin/swapon"
	alias swapoff="/vendor/bin/swapoff"
	alias mkswap="/vendor/bin/mkswap"
fi
}

nandswapControl() {
case $(cat $hybridswap_sign) in
	1)
		sleep 0
		;;
	3)
		# 开关跳过
		sleep 0
		;;
	*)
		toolkit
		for i in $(seq 0 10); do
			swapoff /dev/block/zram0 2>/dev/null
			swapoff /dev/block/zram1 2>/dev/null
			swapoff /dev/block/zram2 2>/dev/null
			sleep 1
		done

		# losetup -f; sleep 1
		# loop_device=$(losetup -f -s $swapfile_path 2>&1)
		# loop_device_ret=`echo $loop_device |awk -Floop '{print $1}'`
		# losetup -d $loop_device 2>/dev/null
		# mkswap $swapfile_path >/dev/null
		# losetup $loop_device $swapfile_path >/dev/null

		swapon /dev/block/zram0 -p 0 >/dev/null

		echo 1 >$hybridswap_sign
		;;
esac
}

nandswapControl

