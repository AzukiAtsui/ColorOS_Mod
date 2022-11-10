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

start=`date +%s`
SKIPUNZIP=1
$BOOTMODE || abort " ColorOS_Mod cannot be installed in recovery."
[ "$ARCH" == "arm64" ] || abort " ColorOS_Mod only support arm64 platform."
nvid=`getprop ro.build.oplus_nv_id`
[ -z "$nvid" ] && abort " Not ColorOS or realmeUI !"
# What is API Level? See <https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels>
if [ $API -lt 30 ]; then abort " Not support Android 10 and older Android version."
elif [ $API -eq 30 ]; then echo " Hello, Android 11 user. •ᴗ•"
elif [ $API -le 32 ]; then echo " Hello, Android 12 user. ❛‿˂̵✧"
elif [ $API -eq 33 ]; then echo " Hello, Android 13 user. (＾Ｕ＾)ノ~"
fi
unzip -o "$ZIPFILE" -x 'META-INF/*' customize.sh -d $MODPATH >&2

ColorOS_MOD_INSTALL_PATH=$MODPATH
ColorOS_MOD_CONFIG=$ColorOS_MOD_INSTALL_PATH/config
ColorOS_MOD_SCRIPT=$ColorOS_MOD_INSTALL_PATH/script
ColorOS_MOD_SIGN=$ColorOS_MOD_INSTALL_PATH/sign
ColorOS_MOD_BIN=$ColorOS_MOD_INSTALL_PATH/bin
chmod +x `find $ColorOS_MOD_BIN/*`
export PATH="$ColorOS_MOD_BIN:$PATH"

# 安装前，在模块包/config/switches.sh 确认修改的文件
source $ColorOS_MOD_CONFIG/switches.sh
# 如果只想取消对文件的部分修改，
# 在此文件“开始修改”下方的 sed 命令行前加井号。

# 载入白名单  允许自启  allow auto-launch
source $ColorOS_MOD_CONFIG/whitelist
# 载入黑名单应用包名  禁止自启  disallow auto-launch
source $ColorOS_MOD_CONFIG/blacklist

# 'Dark mode for 3rd-party apps' can apply Dark mode to apps that do not already contain a dark mode option. It might not work properly for some apps, which supposed to be listed their app package name in 'ColorOS_Mod.zip/config/blacklist_dark'.

# print system info
source $ColorOS_MOD_SCRIPT/sysprop.sh

# print module info
MODVER=`grep_prop version $TMPDIR/module.prop`
MODVCD=`grep_prop versioncode $TMPDIR/module.prop`
MODDES=`grep_prop description $TMPDIR/module.prop`
echo ""
echo "- ** 模块信息 (MODULE INFO) **"
echo "- 名称 (name) : $MODNAME"
echo "- 版本 (version) : $MODVER"
echo "- 版本号 (versioncode) : $MODVCD"
echo "- 作者 (author) : $MODAUTH"
echo "- 描述 (description) : $MODDES"
echo ""

ColorOS_MOD_DIR=$NVBASE/modules/$MODID
if [ -f $ColorOS_MOD_DIR/post-fs-data.sh ]; then
	cat $ColorOS_MOD_DIR/post-fs-data.sh | grep 'mount --bind' | sed -n 's/^[# ]*mount --bind .* \//umount \//g;p' >$TMPDIR/umount.sh
	. $TMPDIR/umount.sh 2>/dev/null
fi


sn=1
echo2n() { echo -e "\n\nNo. $sn"; sn=$(($sn+1)); }

pfds=$ColorOS_MOD_INSTALL_PATH/post-fs-data.sh
mountPfd() {
	pfdDir=$(dirname "$1" | sed -e 's|^/vendor/|/system&|' -e 's|^/product/|/system&|' -e 's|^/system_ext/|/system&|')
	[ -d "$ColorOS_MOD_INSTALL_PATH$pfdDir" ] || mkdir -p "$ColorOS_MOD_INSTALL_PATH$pfdDir"
	# echo "- 将复制 $1 到模块后修改"
	cp -rf "$1" "$ColorOS_MOD_INSTALL_PATH$pfdDir"
	pfd="$ColorOS_MOD_INSTALL_PATH$pfdDir/${1##*/}"
	echo "mount --bind \$MODDIR$pfdDir/${1##*/} $1" >>$pfds
}

blMv() {
	sed -i -e 's/[[:space:]]*<\!--.*-->[[:space:]]*//g' -e '/<\!--/,/-->/c'"" $pfd ;# 清理注释
	sed -i '/^[[:space:]]*$/d' $pfd ;# 清理空行
}

tplFUN() {
	if [ -f $1 ]; then
		mountPfd $1
		echo "- 开始修改$2：$1"
		$3
		blMv
		echo "✔ 修改$2完成"
		[ -z "$4" ] || echo -e "* $4"
	else echo "✘ 不存在$2：$1"
	fi
}

ckFUN() {
	echo2n
	local SRC NM FUN PSI MC
		SRC="$1"; NM="$2文件"; FUN=$3; PSI="$4"; MC="$5"
	if [ -z "$SRC" ]; then
		echo "✘ 未定义$NM"
		[ -z "$MC" ] || echo "* 可能的原因：$MC"
	else
		tplFUN "$SRC" "$NM" $FUN "$PSI"
	fi
}


echo -e "\n\n######### 开始修改系统文件 #########"

echo2n
if [[ "$(cat /sys/devices/soc0/family)" == "Snapdragon" ]]; then echo -e "\n* 修改 dtbo 支持高通平台设备！但很不稳定！\n"
else unset switch_dtbo; echo "* 修改 dtbo 仅支持高通平台设备！"
fi
if [[ "$switch_dtbo" == "TRUE" ]]; then echo "- 开始修改 dtbo镜像"
	# Once dtbo or other critical partitions had been flashed, Android Verified Boot must be disabled just in case RED STATE STUCK or BOOT-LOOP.
	if [ `cat $ColorOS_MOD_DIR/sign/dtbo` -eq 1 ]; then echo "✔ 已刷入过修改后的 dtbo"; echo 1 >$ColorOS_MOD_SIGN/dtbo; fi
	bash $ColorOS_MOD_SCRIPT/dts.sh
	case $? in
		0) echo -e "* 大概是修改并刷入成功了\n★ 请勿删除或移动 $ColorOS_MOD_DIR 目录的原版dtbo\n★ 在将来，卸载 ColorOS_Mod 时会刷回原版 dtbo";;
		14) echo "E! 无可用的dts配置文件";;
		13) echo "E! 无可用的dtc二进制文件";;
		12) echo "E! 无可用的mkdtimg二进制文件";;
		11) echo "E! 无可用的bash二进制文件";;
		8) echo "E! Jeez, 修改失败了！";;
		5) echo "* 这次没有改 dtbo，但可以继续下面的修改";;
		4) echo "E! 构建dtbo失败，导致没有可刷的dtbo";;
	esac
else echo "- 跳过修改 dtbo镜像"; echo 3 >$ColorOS_MOD_SIGN/dtbo; fi

echo2n
if [ "$switch_splash" == "1" ]; then echo "- 开始修改 splash/logo镜像(开机第一屏)"
	if [ "`cat $ColorOS_MOD_DIR/sign/splash`" == "1" ]; then echo "✔ 已刷入过修改后的 splash/logo"; echo 1 >$ColorOS_MOD_SIGN/splash; fi
	bash $ColorOS_MOD_SCRIPT/opsplash.sh
	case $? in
		0) echo -e "* 刷入成功\n★ 请勿删除或移动 $ColorOS_MOD_DIR 目录的splash.img\n★ 在将来，卸载 ColorOS_Mod 时会刷回原版splash.img";;
		255) echo "* 这次没有改开机第一屏，但可以继续下面的修改";;
	esac
else echo "- 跳过修改 splash/logo镜像"; echo 3 >$ColorOS_MOD_SIGN/splash; fi

echo2n
case "$switch_cs" in
	1) echo "✔ 启用时间显秒"; settings put secure clock_seconds 1 ;;
	*) echo "✘ 禁用时间显秒"; settings put secure clock_seconds 0 ;;
esac

FUN_fccas() {
	sed -i '/disable_fp_blind_unlock/d' $pfd || abort "﹗ 未知错误！请联系开发者修复！"
	sed -i -e '/enable_fp_blind_unlock/d' -e '/<extend_features>/a <app_feature name="com.android.systemui.enable_fp_blind_unlock"/>' $pfd && echo "试图去除对息屏指纹盲解的禁用，可能有效"
	sed -i '/disable_volume_blur/d' $pfd && echo "[删除] 禁用音量面板模糊"
}
ckFUN "$src_fccas" " ColorOS 13 系统设置延伸特性" FUN_fccas

FUN_rpref(){
	sed -i '/move_dc_to_develop/d' $pfd && echo "[删除] 移动DC调光到开发者选项设置"
}
ckFUN "$src_rpref" " realmeUI 3.0~4.0 系统设置延伸特性" FUN_rpref

FUN_rcc(){
	sed -i 's/rateId="[0-9]-[0-9]-[0-9]-[0-9]/rateId="3-1-2-3/g' $pfd && echo "[修改] APP刷新率模式为 3-1-2-3，与设置的屏幕刷新率匹配"
	sed -i 's/enableRateOverride="true/enableRateOverride="false/g' $pfd && echo "[禁用] surfaceview，texture场景降帧"
	sed -i 's/disableViewOverride="true/disableViewOverride="false/g' $pfd && echo "[禁用] disableViewOverride"
	sed -i 's/inputMethodLowRate="true/inputMethodLowRate="false/g' $pfd && echo "[禁用] 输入法降帧"
	sed -i 's/adfr="true/adfr="false/g' $pfd && echo "[禁用] 动态刷新率"
}
ckFUN "$src_rrc" "屏幕刷新率重点应用名单" FUN_rcc "注意：系统设置刷新率仍然生效"

FUN_ovc(){
	echo "备份关键项……"
	sed -n -e '/"filter_name/i {' -e '/"filter_name/a },' -e '/"filter_name/p' $pfd >$TMPDIR/adfrkey
	sed -n -e '/"version/i {' -e '/"version/a },' -e '/"version/p' $pfd >>$TMPDIR/adfrkey
	sed -n -e '/"sub_version/i {' -e '/"sub_version/a },' -e '/"sub_version/p' $pfd >>$TMPDIR/adfrkey
	sed -n -e '/"touch_idle/i {' -e '/"adfr_enable/a },' -e '/"adfr_enable/p' -e '/"sw_enable/p' -e '/"hw_enable/p' -e '/"touch_idle/p' $pfd >>$TMPDIR/adfrkey
	sed -n -e '/"cvt/i {' -e '/"cvt/a },' -e '/"cvt/p' $pfd >>$TMPDIR/adfrkey
	sed -n -e '/"frtc/i {' -e '/"frtc/a }' -e '/"frtc/p' $pfd >>$TMPDIR/adfrkey
	sed -i -e '1i [' -e '$a ]' $TMPDIR/adfrkey
	cp -f $TMPDIR/adfrkey $pfd
	sed -i -e '/"touch_idle"/s/true/false/' -e '/"hw_enable"/s/true/false/' -e '/"sw_enable"/s/true/false/' -e '/"adfr_enable"/s/true/false/' $pfd && echo "[禁用] touch_idle, hw, sw, adfr"
}
if [ $API -gt 30 ]; then
	[[ "$product_brand" == "realme" ]] && ckFUN "$src_ovc" "动态刷新率(adfr) " FUN_ovc;
fi;

FUN_mdpl(){
	sed -i -e '/<fps>/d' -e '/<vsync>/d' $pfd && echo "[删除] 锁帧、垂直同步设置"
}
ckFUN "$src_mdpl" "视频播放器帧率控制" FUN_mdpl "设置120hz时，播放视频可120hz"

FUN_fcl(){
	echo2n
	[ -d "$ColorOS_MOD_INSTALL_PATH${1%/*}" ] || mkdir -p "$ColorOS_MOD_INSTALL_PATH${1%/*}"
	echo "- 开始修改$2：$1"
	echo "mount --bind \$MODDIR$1 $1" >>$pfds
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<extend_features>
<app_feature name=\"os.carlink.ocar.xgui\" args=\"boolean:true\" />
<app_feature name=\"os.carlink.carkey\" args=\"boolean:true\" />
<app_feature name=\"os.carlink.carcontrol\" args=\"boolean:true\" />
</extend_features>" >$ColorOS_MOD_INSTALL_PATH$1
	echo "✔ 修改$2完成"
}
[ -f "$src_fcl" ] && FUN_fcl "$src_fcl" "Carlink feature 车联特性文件"

FUN_stcc(){
	sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_\(scene_\)*103/,/com.tencent.mobileqq_\(scene_\)*103/p' $pfd >$TMPDIR/specificScene && echo "[备份] 腾讯QQ 微信 WhatsApp specificScene"
	sed -i '/specificScene/,/\/specificScene/d' $pfd && echo "[删除] specificScene 与 /specificScene 区间行"
	sed -i '/\/screenOff/ r specificScene' $pfd && rm -rf $TMPDIR/specificScene && echo "[写回] 腾讯QQ specificScene"
	sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' $pfd >$TMPDIR/specific && echo "[备份] Oplus相机 specific"
	sed -i '/specific>/,/\/specific>*/d' $pfd && echo "[删除] specific 与 /specific 区间行"
	sed -i '/\/specificScene/ r specific' $pfd && rm -rf $TMPDIR/specific && echo "[写回] Oplus相机 specific"
sed -i 's/fps="[0-9]*/fps="0/g' $pfd && echo "[禁用] 温控锁帧率"
sed -i 's/cpu="-*[0-9]*/cpu="-1/g' $pfd && echo "[修改] CPU -1"
sed -i 's/gpu="-*[0-9]*/gpu="-1/g' $pfd && echo "[修改] GPU -1"
sed -i 's/cameraBrightness="[0-9]*/cameraBrightness="255/g' $pfd && echo "[修改] 相机亮度 255"
	sed -i -e 's/restrict="[0-9]*/restrict="0/g' -e 's/brightness="[0-9]*/brightness="0/g' -e 's/charge="[0-9]*/charge="0/g' -e 's/modem="[0-9]*/modem="0/g' -e 's/disFlashlight="[0-9]*/disFlashlight="0/g' -e 's/stopCameraVideo="[0-9]*/stopCameraVideo="0/g' -e 's/disCamera="[0-9]*/disCamera="0/g' -e 's/disWifiHotSpot="[0-9]*/disWifiHotSpot="0/g' -e 's/disTorch="[0-9]*/disTorch="0/g' -e 's/disFrameInsert="[0-9]*/disFrameInsert="0/g' -e 's/refreshRate="[0-9]*/refreshRate="0/g' -e 's/disVideoSR="[0-9]*/disVideoSR="0/g' -e 's/disOSIE="[0-9]*/disOSIE="0/g' -e 's/disHBMHB="[0-9]*/disHBMHB="0/g' $pfd && echo "[禁用] 部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB"
}
ckFUN "$src_stcc" " ColorOS 系统高温控制配置" FUN_stcc

ckFUN "$src_stcc_gt" " realmeUI GT模式高温控制器" FUN_stcc

FUN_shtp(){
	sed -i '/HighTemperatureProtectSwitch>/s/true/false/g' $pfd && echo "[禁用] 高温保护"
	sed -i '/HighTemperatureShutdownSwitch>/s/true/false/g' $pfd && echo "[禁用] 高温关机"
	sed -i '/HighTemperatureFirstStepSwitch>/s/true/false/g' $pfd && echo "[禁用] 高温第一步骤"
	sed -i '/HighTemperatureDisableFlashSwitch>/s/true/false/g' $pfd && echo "[禁用] 高温禁用手电"
	sed -i '/HighTemperatureDisableFlashChargeSwitch>/s/true/false/g' $pfd && echo "[禁用] 高温禁用闪充"
	sed -i '/HighTemperatureControlVideoRecordSwitch>/s/true/false/g' $pfd && echo "[禁用] 高温视频录制控制"
	sed -i -e '/HighTemperatureShutdownUpdateTime/d' -e '/HighTemperatureProtectFirstStepIn/d' -e '/HighTemperatureProtectFirstStepOut/d' -e '/HighTemperatureProtectThresholdIn/d' -e '/HighTemperatureProtectThresholdOut/d' -e '/HighTemperatureProtectShutDown/d' -e '/HighTemperatureDisableFlashLimit/d' -e '/HighTemperatureEnableFlashLimit/d' -e '/HighTemperatureDisableFlashChargeLimit/d' -e '/HighTemperatureEnableFlashChargeLimit/d' -e '/HighTemperatureDisableVideoRecordLimit/d' -e '/HighTemperatureEnableVideoRecordLimit/d' $pfd && echo "[删除] 部分 Time In/Out Dis/Enable 项"
	sed -i '/camera_temperature_limit>/s/>[0-9]*</>600</g' $pfd && echo "[修改] camera_temperature_limit为600"
	sed -i '/ToleranceFirstStepIn>/s/>[0-9]*</>600</g' $pfd && echo "[修改] ToleranceFirstStepIn为600"
	sed -i '/ToleranceFirstStepOut>/s/>[0-9]*</>580</g' $pfd && echo "[修改] ToleranceFirstStepOut为580"
	sed -i '/ToleranceSecondStepIn>/s/>[0-9]*</>620</g' $pfd && echo "[修改] ToleranceSecondStepIn为620"
	sed -i '/ToleranceSecondStepOut>/s/>[0-9]*</>600</g' $pfd && echo "[修改] ToleranceSecondStepOut为600"
	sed -i '/ToleranceStart>/s/>[0-9]*</>540</g' $pfd && echo "[修改] ToleranceStart为540"
	sed -i '/ToleranceStop>/s/>[0-9]*</>520</g' $pfd && echo "[修改] ToleranceStop为520"
}
ckFUN "$src_shtp" "高温保护" FUN_shtp "请避免手机长时间处于高温状态（约44+℃）\n* 高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"

FUN_stc(){
	sed -i '/is_upload_dcs>/s/1/0/g' $pfd && echo "[禁用] 上传dcs"
	sed -i '/is_upload_log>/s/1/0/g' $pfd && echo "[禁用] 上传log"
	sed -i '/is_upload_errlog>/s/1/0/g' $pfd && echo "[禁用] 上传错误log"
	sed -i '/thermal_battery_temp>/s/1/0/g' $pfd && echo "[禁用] thermal_battery_temp"
	sed -i '/thermal_heat_path/d' $pfd && echo "[删除] thermal_heat_path"
	# OPPO Find X3 <detect_environment_time_threshold>600000</detect_environment_time_threshold> <detect_environment_temp_threshold>30</detect_environment_temp_threshold>
	sed -i '/detect_environment_time_threshold>[0-9]*</d' $pfd && echo "[删除] 环境检测时间阈值"
	sed -i '/detect_environment_temp_threshold>[0-9]*</d' $pfd && echo "[删除] 环境检测温度阈值"
	sed -i '/more_heat_threshold>/s/>[0-9]*</>600</g' $pfd && echo "[修改] more_heat_threshold为600"
	sed -i '/<heat_threshold>/s/>[0-9]*</>580</g' $pfd && echo "[修改] heat_threshold为580"
	sed -i '/less_heat_threshold>/s/>[0-9]*</>560</g' $pfd && echo "[修改] less_heat_threshold为560"
	sed -i '/preheat_threshold>/s/>[0-9]*</>540</g' $pfd && echo "[修改] preheat_threshold为540"
	sed -i '/preheat_dex_oat_threshold>/s/>[0-9]*</>520</g' $pfd && echo "[修改] preheat_dex_oat_threshold为520"
}
ckFUN "$src_stc" "高热配置" FUN_stc "请避免手机长时间处于高温状态（约44+℃）\n* 高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"

echo2n
if [ -d $src_horae ]; then echo "- 检测到存在加密温控目录，尝试模块替换为空"
REPLACE="
/system/system_ext/etc/horae
"
else echo "✘ 不存在定义的加密温控目录"; fi

echo2n
if [[ "$switch_thermal" == "TRUE" ]]; then
	for thermalTemp in `find /sys/devices/virtual/thermal/ -iname "*temp*" -type f`; do wint=`cat $thermalTemp`
		[[ -z "$wint" ]] && continue
		echo "`realpath $thermalTemp` 当前参数：$wint"
		alias echoTt=echo "改善参数：`cat $pfd` 到`realpath $thermalTemp`"
		[[ $wint -lt 40000 || $wint -ge 55000 ]] && continue
		mountPfd $thermalTemp
		if [ $wint -lt 45000 ]; then echo 45000 >$pfd; echoTt
			# chown -h adb.adb $pfd
		elif [ $wint lt 55000 ]; then
			# 假如默认参数大于等于45℃并且小于55℃，就改成55℃
			echo 55000 >$pfd; echoTt
		# elif [ $wint -lt 65000 ]; then echo 65000 >$pfd; echoTt
		# elif [ $wint -lt 75000 ]; then echo 75000 >$pfd; echoTt
		# elif [ $wint -lt 85000 ]; then echo 85000 >$pfd; echoTt
		# elif [ $wint -lt 95000 ]; then echo 95000 >$pfd; echoTt
		# elif [ $wint -lt 105000 ]; then echo 105000 >$pfd; echoTt
		fi; done
	echo "✔ 修改温控节点温度阈值完成"
else echo "- 跳过修改温度阈值";fi

# find /system /vendor /product /odm /system_ext -type f -iname "*thermal*" -exec ls -s -h {} \; 2>/dev/null | sed '/hardware/d' ;# swap to 0, may cause STUCK.

FUN_apn() {
	sed -i '/read_only/s/true/false/g' $pfd && echo "[禁用] 自带接入点修改限制"
}
ckFUN "$src_apn" "自带APN接入点配置" FUN_apn

echo2n
if [ ! -z "$list_hybridswap" ]; then echo "- 尝试在安装有面具的情况下开启内存拓展"
	# 欧加内存拓展管理脚本为 '/product/bin/init.oplus.nandswap.sh'
	resetprop persist.sys.oplus.nandswap.condition true
	echo 1 >/sys/block/zram0/hybridswap_dev_life
else echo "- 跳过激活内存拓展"; echo 3 >$ColorOS_MOD_SIGN/hybridswap; fi

FUN_smac(){
	sed -i 's/maxNum name="[0-9]*/maxNum name="2000/' $pfd && echo "[修改] 分身应用数量限制为2000" ;# 2000 for 21th century.
	for APKN in $APKNs; do multiAPKN="<item name=\"$APKN\" \/>"
		sed -i -e "/$multiAPKN/d" -e '/<allowed>/a'"$multiAPKN" $pfd && echo "去重添加包名$APKN 到$NM" >&2
	done
	sed -i '1i'"appClonerList=$ColorOS_MOD_DIR$pfdDir/${SRC##*/}" $ColorOS_MOD_INSTALL_PATH/service.sh
}
ckFUN "$src_smac" "应用分身配置（App cloner config）" FUN_smac

echo -e "\n\n\n\n######### 以下编辑 /data/ 目录内文件 #########"

FUN_blacklistMv(){
	for APKN in $blacklistAPKNs; do
		sed -i "/$APKN/d" $pfd && echo "[删除] 含有黑名单应用包名$APKN的行" >&2
	done
}
ckFUN "$src_blacklistMv" "启动管理" FUN_blacklistMv

ckFUN "$src_blacklistMv3c" "启动V3配置列表" FUN_blacklistMv

# Add path of $SRC as a varible named "${2}List" to 'service.sh' for update list at restarted.
apknlu() {
	if [[ "$SRC" == "$1" ]]; then
		sed -i '2i'"${2}List=$ColorOS_MOD_DIR$pfdDir/${SRC##*/}" $ColorOS_MOD_INSTALL_PATH/service.sh;
	fi;
}

FUN_sdmtam(){
	# delete incompatible app package names
	echo "$APKNs" >$TMPDIR/APKNs;
	for b in `cat $ColorOS_MOD_CONFIG/blacklist_dark`; do
		sed -i "/$APKN/d" $pfd && echo "[删除] 含有 'config/blacklist_dark' 列出的 $APKN 的行" >&2;
		sed -i "/$b\$/d" $TMPDIR/APKNs;
	done;
	trueDark=`cat $TMPDIR/APKNs`;
	for APKN in $trueDark; do darkAPKN="<p attr=\"$APKN\"\/>";
		sed -i -e "/$APKN/d" -e '/<\/filter-conf>/i'"$darkAPKN" $pfd && echo "去重添加包名$APKN 到$NM" >&2;
	done;
	apknlu $src_sdmtam dark;
	function co(){
		dca=${src_sdmtam%/*}/$1;
		rm -rf $dca; echo '' >$dca; set_perm $dca 1000 1000 600 600;
		mdca=$ColorOS_MOD_INSTALL_PATH$dca;
		cp -f "$TMPDIR/APKNs" "$mdca";
		echo "mount --bind \$MODDIR$dca $dca" >>$pfds;
	};
	co open_app;
	co click_app;
	local SRC=${src_sdmtam%/*}/click_app; apknlu "$SRC" darkC;
	local SRC=${src_sdmtam%/*}/open_app; apknlu $SRC darkO;
}
ckFUN "$src_sdmtam" "暗色模式第三方应用管理" FUN_sdmtam "“三方应用暗色”可以将自身不支持暗色的应用调整为适合暗色模式下使用的效果。\n* 部分应用开启后可能会出现显示异常，\n* 可以将其包名从 $ColorOS_MOD_DIR${src_sdmtam%/*}/open_app\n　　　　开启名单↑删除"

apknAdd() {
	for APKN in $APKNs; do
		sed -i -e "/$APKN\$/d" -e '$a'"$APKN" $pfd && echo "去重添加包名$APKN 到$NM" >&2;
	done;
	for APKN in $blacklistAPKNs; do sed -i "/$APKN\$/d" $pfd && echo "[删除] 含有黑名单应用包名$APKN的行" >&2; done;
	apknlu $src_awl autostartWhite;
	apknlu $src_bwl bootWhite;
}
# ckFUN "$src_bootwhitelist" " ColorOS 11~12 自启动白名单 或 ColorOS 13 允许自启动应用名单" apknAdd
if [ $API -lt 33 ]; then
	ckFUN "$src_bwl" " ColorOS 11~12 自启动白名单" apknAdd
fi

# ckFUN "$src_asw" " ColorOS 11 允许关联启动名单" apknAdd

# ckFUN "$src_acwl" " ColorOS 12~13 关联启动名单白名单" apknAdd

# ckFUN "$src_ba" " ColorOS 11~12 允许自启动应用名单" apknAdd "" "①注释了定义变量，②安卓13 设备，不存在bootallow.txt"

ckFUN "$src_awl" " ColorOS 13 自启动白名单" apknAdd "" "①注释了定义变量，②不存在autostart_white_list.txt"

FUN_bgApp(){
	sed -i '/lock_app_limit/s/value="[0-9]*/value="2000/' $pfd && echo "[修改] 锁定后台数量限制为2000"
}
ckFUN "$src_bgApp" "系统桌面 (OPPO/Oplus launcher) 锁定后台数量限制配置" FUN_bgApp

FUN_spea(){
	sed -i 's|protectapp.*protectapp>|protectapp />|g' $pfd && echo "[修改] 清空<protectapp />标签"
}
ckFUN "$src_spea" "安全支付的启用应用名单" FUN_spea "请自行注意网络、ROOT权限应用等环境的安全性！谨防上当受骗！"

# 注释掉多余挂载命令行
sed -i 's|^mount --bind \$MODDIR/system/|# &|g' $pfds

set_perm_recursive $ColorOS_MOD_INSTALL_PATH 0 0 755 644

# 安装内置的二进制文件
MBD=$ColorOS_MOD_INSTALL_PATH/system/bin
[ -d $MBD ] || mkdir -p $MBD
set_perm_recursive $ColorOS_MOD_BIN 0 0 755 755
for i in `find $ColorOS_MOD_BIN/* -prune`; do ln $i $MBD/${i##*/}; done

# 清理临时文件
DTSTMP=$ColorOS_MOD_INSTALL_PATH/dts
rm -rf "$DTSTMP" >/dev/null 2>&1

end=`date +%s`
echo -e "\n\n✔ 模块安装完成。耗时：`expr $end - $start`s\n* 修改在重启后生效\n Enjoy the modification. ^ω^"

