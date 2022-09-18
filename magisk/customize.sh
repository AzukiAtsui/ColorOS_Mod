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

SKIPUNZIP=1
# 各安卓平台版本所支持的API 级别见 [Android 开发者指南](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels) 
if [ $API -le 30 ];then
	abort "不支持Android 11 及以下。仅对Android 12 ~ 13 的ColorOS 和 realmeUI 生效"
elif [ $API -lt 33 ];then
	echo " 你好，安卓12 用户。 ❛‿˂̵✧"
elif [ $API -eq 33 ];then
	echo " 你好，安卓13 用户。 (＾Ｕ＾)ノ~"
fi
unzip -o "$ZIPFILE" -x 'META-INF/*' customize.sh -d $MODPATH >&2

#
######### 在下方确认修改的文件 #########
#
# 在不需要修改的文件变量定义命令行开头加 '#'（井号）来在模块安装阶段跳过对它们的所有修改。变量是指 '='（等号）前 src_*、switch_* 的英文。
# 例：
#	# [ -f $i ] && src_smac=$i
#
# 如果只想取消对文件的部分修改，
# 在更下方的“开始编辑配置文件”的 sed 命令行前加井号。
#

# dtbo镜像
switch_dtbo=TRUE
# 2022-09-12 支持真我GT2 Pro、真我GT Neo2、一加9 Pro 更改dtbo充电温控墙; realme及OPPO使用的VOOC需要内核去除智慧闪充才能生效; 感谢 酷安@init萌新很新

# ColorOS 13 息屏指纹盲解
src_fccas=/my_product/etc/extension/feature_common_com.android.systemui.xml

# 刷新率名单
src_rrc=/my_product/etc/refresh_rate_config.xml

# 动态刷新率(adfr)
src_ovc=/my_product/etc/oplus_vrr_config.json

# 去除视频锁帧
src_mdpl=/my_product/vendor/etc/multimedia_display_perf_list.xml

# 去除ColorOS（ realme 非GT模式）游戏锁帧率等限制
src_stcc=/odm/etc/temperature_profile/sys_thermal_control_config.xml

# 去除 realme GT模式游戏锁帧率: fps="0; 修改GPU、CPU为 -1 ; 限制 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 后面的值都改成0
src_stcc_gt=/odm/etc/temperature_profile/sys_thermal_control_config_gt.xml

# 修改温控 高温保护
src_shtp=/odm/etc/temperature_profile/$(for i in /odm/etc/temperature_profile/sys_high_temp_protect*.xml;do echo ${i##*/};done)

# 修改温控
src_stc=/odm/etc/ThermalServiceConfig/sys_thermal_config.xml

# 清空加密温控
src_horae=/system_ext/etc/horae

# 修改温控节点温度阈值
# switch_thermal=TRUE

# 解除自带接入点修改限制
src_apn=/system/product/etc/apns-conf.xml

# 内存拓展
list_hybridswap=$(ls -l /sys/block/zram0/hybridswap_* | grep ^'\-rw\-' | awk '{print $NF}')

# 应用分身/App Cloner; Android 12 ~ 13 同路径
## src_smac=$(find /system /system_ext -type f -name sys_multi_app_config.xml | sed 1n) ; # 文件名查找文件费时间
for i in /system_ext/oppo/sys_multi_app_config.xml /system_ext/oplus/sys_multi_app_config.xml;do
	[ -f $i ] && src_smac=$i
	if [ -z $src_smac ];then
		echo " ✘ 不存在ColorOS 应用分身/App Cloner 配置文件：$i" >&2
	else
		break
	fi
done

# 从启动管理 删除黑名单应用（由下方 blacklistAPKNs 变量定义）
for i in /data/oppo/coloros/startup/startup_manager.xml /data/oplus/os/startup/startup_manager.xml;do
	[ -f $i ] && src_blacklistMv=$i
	if [ -z $src_blacklistMv ];then
		echo " ✘ 不存在ColorOS 启动管理：$i" >&2
	else
		break
	fi
done
# 从系统启动V3配置表 删除黑名单应用
for i in /data/oppo/coloros/startup/sys_startup_v3_config_list.xml /data/oplus/os/startup/sys_startup_v3_config_list.xml;do
	[ -f $i ] && src_blacklistMv3c=$i
	if [ -z $src_blacklistMv3c ];then
		echo " ✘ 不存在ColorOS 系统启动V3配置表：$i" >&2
	else
		break
	fi
done

# ColorOS 12 自启动白名单 系统推荐自启动的App包名列表 不在bootwhitelist.txt中的App占用不推荐自启的名额; Android 13 变为允许自启动而非推荐
for i in /data/oppo/coloros/startup/bootwhitelist.txt /data/oplus/os/startup/bootwhitelist.txt;do
	[ -f $i ] && src_bootwhitelist=$i
	if [ -z $src_bootwhitelist ];then
		echo " ✘ 不存在ColorOS 12 自启动白名单 或 ColorOS 13 自启动允许名单文件：$i" >&2
	else
		break
	fi
done

# ColorOS 关联启动白名单
for i in /data/oppo/coloros/startup/associate_white_list.txt /data/oplus/os/startup/associate_white_list.txt;do
	[ -f $i ] && src_acwl=$i
	if [ -z $src_acwl ];then
		echo " ✘ 不存在ColorOS 关联启动白名单：$i" >&2
	else
		break
	fi
done

# 自启动允许名单 ColorOS 12: /data/oppo/coloros/startup/bootallow.txt ; realmeUI Android 12: /data/oplus/os/startup/bootallow.txt
if [[ $API -lt 33 ]];then
	for i in /data/oppo/coloros/startup/bootallow.txt /data/oplus/os/startup/bootallow.txt;do
		[ -f $i ] && src12_bootallow="$i"
		if [ -z $src12_bootallow ];then
			echo " ✘ 不存在ColorOS 12 自启动允许名单文件：$i" >&2
		else
			break
		fi
	done
fi
# Android 13 版本
if [[ $API -eq 33 ]];then
	for i in /data/oppo/coloros/startup/autostart_white_list.txt /data/oplus/os/startup/autostart_white_list.txt;do
		[ -f $i ] && src13_awl="$i"
		if [ -z $src13_awl ];then
			echo " ✘ 不存在ColorOS 13 自启动白名单文件：$i" >&2
		else
			break
		fi
	done
fi

# 第三方应用暗色模式文件 内含可强制启用深色模式的App包名
for i in /data/oplus/os/darkmode/sys_dark_mode_third_app_managed.xml /data/oppo/coloros/darkmode/sys_dark_mode_third_app_managed.xml;do
	[ -f $i ] && src_sdmtam=$i
	if [ -z $src_sdmtam ];then
		echo " ✘ 不存在ColorOS 暗色模式第三方应用管理名单文件：$i" >&2
	else
		break
	fi
done

# 最近任务管理可锁定数量
src_bgApp=/data/user_de/0/com.android.launcher/shared_prefs/Configuration.xml

# 禁用ROOT后打开支付软件时的报毒，需要禁用支付安全环境扫描，可以在系统设置里面手动关闭
src_spea=/data/data/com.coloros.securepay/files/enabledapp.xml

#
######### 在上方确认修改的文件 #########
#




APKNs=$(pm list packages -e -3 | sed 's/.*://')
# 黑名单应用包名，从自启名单删除它们
blacklistAPKNs="
com.xunmeng.pinduoduo
com.nearme.instant.platform
com.heytap.book
com.oppo.book
"


function chkNvid(){
nvid=$(getprop ro.build.oplus_nv_id)
if [ $nvid -eq 10010111 ];then
echo 国行版
elif [ $nvid -eq 00011010 ];then
echo 台湾版
elif [ $nvid -eq 00010111 ];then
echo 印度版
elif [ $nvid -eq 01000100 ];then
echo 欧洲版
else
echo "未知地区，nv_id = $nvid"
fi
}

ui_print "

ColorOS_Mod-MagiskModule version : $(grep_prop version $TMPDIR/module.prop)

- * Info of the device（设备信息）*
- 商品名 : $(getprop ro.vendor.oplus.market.name)
- 品牌 : `getprop ro.product.brand`
- 型号 : `getprop ro.product.model`
- 代号 : `getprop ro.product.device`
- 项目 : `getprop ro.boot.prjname`
- 地区 : `getprop ro.product.locale`
- nv_id : `chkNvid`
- ColorOS 版本 : `getprop ro.build.version.oplusrom.display`
- Android 版本 : `getprop ro.build.version.release`
- API level (Android version) : $API
- SOC 型号 : `getprop ro.soc.model`
- CPU architecture : $ARCH
- 内核版本 : `uname -a`
- 运存大小 : `free -m|grep "Mem"|awk '{print $2}'` MB ; 已用: `free -m|grep "Mem"|awk '{print $3}'` MB ; 剩余: $((`free -m|grep "Mem"|awk '{print $2}'`-`free -m|grep "Mem"|awk '{print $3}'`)) MB
- Swap大小 : `free -m|grep "Swap"|awk '{print $2}'` MB ; 已用: `free -m|grep "Swap"|awk '{print $3}'` MB ; 剩余: `free -m|grep "Swap"|awk '{print $4}'` MB"


chmod +x $(find $MODPATH/bin)
damCM=/data/adb/modules/coloros_mod
if [ -f $MODPATH/bin/bash ];then
	alias BASH=$MODPATH/bin/bash
	echo "将使用模块内置的 GNU Bash"
elif [ -f /data/user/0/com.termux/files/usr/bin/bash ];then
	alias BASH=/data/user/0/com.termux/files/usr/bin/bash
	echo "尝试用 termux 内置的 bash"
elif [ -f /data/user/0/bin.mt.plus/files/term/usr/bin/bash ];then
	alias BASH=/data/user/0/com.termux/files/usr/bin/bash
	echo "尝试用 MT管理器 内置的 bash"
else
	abort "有时竟一个 bash 都没有！"
fi

if [ -f $damCM/post-fs-data.sh ];then
cat $damCM/post-fs-data.sh | grep 'mount --bind' | sed -n 's/^[# ]*mount --bind .* \//umount \//g;p' >$TMPDIR/umount.sh
. $TMPDIR/umount.sh 2>/dev/null
fi
pfds=$MODPATH/post-fs-data.sh


sn=1
echo2n() {
	# sleep 1
	echo -e "\n\nNo. $sn"
	sn=$(($sn+1))
}

mountPfd() {
	pfdDir=$(dirname $1 | sed -e 's/^\/vendor\//\/system\/vendor\//' -e 's/^\/product\//\/system\/product\//' -e 's/^\/system_ext\//\/system\/system_ext\//')
	[ -d $MODPATH$pfdDir ] || mkdir -p $MODPATH$pfdDir
	# echo "将复制文件 $1 到模块后修改"
	cp -rf $1 $MODPATH$pfdDir
	pfd=$MODPATH$pfdDir/${1##*/}
		if [ -f $pfd ];then
			echo "mount --bind \$MODDIR$pfdDir/${1##*/} $1" >>$pfds
		else
			abort " ✘ 模块目录下竟然没有需编辑的 $pfd 文件，请联系开发者修复！"
		fi
}

apknAdd() {
if [ -f $1 ];then
	mountPfd $1
	echo "－开始编辑$2：$1"
	for APKN in $APKNs
	do
		sed -i '/'$APKN'$/d' $pfd
		sed -i '$a'$APKN $pfd && echo "已去重添加包名：$APKN 到$2" >&2
	done
	for APKN in $blacklistAPKNs
	do
		sed -i '/'$APKN'$/d' $pfd && echo " ✘ 已从$2删除黑名单应用 包名：$APKN" >&2
	done
	echo "修改$2完成"
fi
}

blMv() {
	sed -i 's/<\!--.*-->//g' $pfd ;# 删除注释
	sed -i '/^[ \t]*$/d' $pfd ;# 删除空行
}




echo "

######### 开始修改配置文件 #########"

echo2n
if [[ $switch_dtbo == TRUE ]];then
	echo "－开始修改 dtbo镜像"
	[ $(cat $damCM/dtbo_sign ) -eq 1 ] && echo " ✔ 已安装过 dtbo" && echo 1 >$MODPATH/dtbo_sign
	BASH $MODPATH/dts.sh >&2
	if [ $? -eq 0 ];then
		echo -e "大概是修改并刷入成功了\n欲知详情请保存安装日志（通常在右上角）\n请勿删除或移动 $damCM 目录的原版dtbo\n在将来，卸载 ColorOS_Mod 时会刷回原版 dtbo"
	elif [ $? -eq 404 ];then
		echo " ✘ 不支持的机型，原因：getprop ro.product.vendor.model 空值"
	elif [ $? -eq 14 ];then
		echo "没有当前设备 `getprop ro.product.vendor.model` 的dts配置"
	elif [ $? -eq 13 ];then
		echo "dtc二进制文件丢失，模块损坏？"
	elif [ $? -eq 12 ];then
		echo "mkdtimg二进制文件丢失，模块损坏？"
	elif [ $? -eq 5 ];then
		echo "虽然没有改 dtbo，但可以继续下面的修改"
	fi
else
	echo "开关已关闭，跳过修改 dtbo镜像"
	echo 3 >$MODPATH/dtbo_sign
fi

echo2n
function FNCNfccas() {
if [ -f $src_fccas ];then
	mountPfd $src_fccas
	echo "－开始编辑ColorOS 13 系统设置特性配置文件：$src_fccas"
	sed -i 's/<app_feature name=\"com.android.systemui.disable_fp_blind_unlock\"\/>//g' $pfd || abort "未知错误！请联系开发者修复！"
	echo "已去除对息屏指纹盲解的禁用"
	blMv
	echo "修改ColorOS 13 系统设置特性配置文件完成"
else
	echo " ✘ 不存在ColorOS 13 系统设置特性配置文件：$src_fccas" >&2
fi
}
if [ -z $src_fccas ];then
echo "未定义 ColorOS 13 系统设置特性配置 文件"
else
FNCNfccas
fi

echo2n
function FNCNrcc(){
if [ -f $src_rrc ];then
	mountPfd $src_rrc
	echo "－开始编辑ColorOS 屏幕刷新率应用配置文件：$src_rrc"
	sed -i 's/rateId=\"[0-9]-[0-9]-[0-9]-[0-9]/rateId=\"3-1-2-3/g' $pfd && echo "已全局改刷新率模式为 3-1-2-3"
	sed -i 's/enableRateOverride=\"true/enableRateOverride=\"false/g' $pfd && echo "surfaceview，texture场景不降"
	sed -i 's/disableViewOverride=\"true/disableViewOverride=\"false/g' $pfd && echo "已关闭disableViewOverride"
	sed -i 's/inputMethodLowRate=\"true/inputMethodLowRate=\"false/g' $pfd && echo "已关闭输入法降帧"
	blMv
	echo -e "修改ColorOS 屏幕刷新率重点应用名单完成\n注意：系统设置刷新率仍然生效"
else
	echo " ✘ 不存在ColorOS 屏幕刷新率应用配置文件：$src_rrc" >&2
fi
}
if [ -z $src_rrc ];then
echo "未定义 屏幕刷新率应用配置 文件"
else
FNCNrcc
fi

echo2n
function FNCNovc(){
if [ -f $src_ovc ];then
	mountPfd $src_ovc
	echo "－开始编辑ColorOS 动态刷新率(adfr)文件：$src_ovc"
	sed -i '/\"blacklist\"/,/[\s\S]*\s*\]/d' $pfd && echo "已删除黑名单"
	sed -i -e '/"timeout": [0-9]*,/d' -e '/"hw_brightness_limit": [0-9]*,/d' -e '/"hw_gray": true,/d' -e '/"hw_gray_threshold": [0-9]*,/d' -e '/"hw_gray_percent": [0-9]*,/d' $pfd && echo "已删除多余内容"
	echo "修改ColorOS 动态刷新率(adfr) 文件完成"
else
	echo " ✘ 不存在ColorOS 动态刷新率(adfr) 文件：$src_ovc" >&2
fi
}
if [ -z $src_ovc ];then
echo "未定义 ColorOS 动态刷新率(adfr) 文件"
else
FNCNovc
fi

echo2n
function FNCNmdpl(){
if [ -f $src_mdpl ];then
	mountPfd $src_mdpl
	echo "－开始编辑ColorOS 视频播放器帧率控制文件：$src_mdpl"
	sed -i -e '/<fps>/d' -e '/<vsync>/d' $pfd && echo "已删除锁帧、垂直同步设置"
	blMv
	echo -e "修改ColorOS 视频播放器帧率控制文件完成\n设置120hz时，播放视频可120hz"
else
	echo " ✘ 不存在ColorOS 视频播放器帧率控制文件：$src_mdpl" >&2
fi
}
if [ -z $src_mdpl ];then
echo "未定义 ColorOS 视频播放器帧率控制 文件"
else
FNCNmdpl
fi

echo2n
function FNCNstcc(){
if [ -f $src_stcc ];then
	mountPfd $src_stcc
	echo "－开始编辑ColorOS 高温控制器文件：$src_stcc"
	sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' $pfd >$TMPDIR/specificScene && echo "已备份腾讯QQ specificScene"
	sed -i '/specificScene/,/\/specificScene/d' $pfd && echo "已删除 specificScene 与 /specificScene 区间行"
	sed -i '/\/screenOff/ r specificScene' $pfd && rm -rf $TMPDIR/specificScene && echo "已写回腾讯QQ specificScene"
	sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' $pfd >$TMPDIR/specific && echo "已备份Oplus相机 specific"
	sed -i '/specific>/,/\/specific>*/d' $pfd && echo "已删除 specific 与 /specific 区间行"
	sed -i '/\/specificScene/ r specific' $pfd && rm -rf $TMPDIR/specific && echo "已写回Oplus相机 specific"
	sed -i '/^[ \t]*$/d' $pfd && rm -rf specific && echo "已删除空行"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' $pfd && echo "已关闭温控锁帧率"
sed -i 's/cpu=\".*\" g/cpu=\"-1\" g/g' $pfd && echo "CPU -1"
sed -i 's/gpu=\".*\" r/gpu=\"-1\" r/g' $pfd && echo "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' $pfd && echo "相机亮度 255"
	sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' $pfd && echo "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB "
	echo "修改ColorOS 高温控制器文件完成"
else
	echo " ✘ 不存在ColorOS 高温控制器文件：$src_stcc" >&2
fi
}
if [ -z $src_stcc ];then
echo "未定义 ColorOS 高温控制器 文件"
else
FNCNstcc
fi

echo2n
function FNCNstcc_gt(){
if [ -f $src_stcc_gt ];then
	mountPfd $src_stcc_gt
	echo "－开始编辑 realme GT模式高温控制器文件：$src_stcc_gt"
	sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' $pfd >$TMPDIR/specificScene && echo "已备份腾讯QQ specificScene"
	sed -i '/specificScene/,/\/specificScene/d' $pfd && echo "已删除 specificScene 与 /specificScene 区间行"
	sed -i '/\/screenOff/ r specificScene' $pfd && rm -rf $TMPDIR/specificScene && echo "已写回腾讯QQ specificScene"
	sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' $pfd >$TMPDIR/specific && echo "已备份Oplus相机 specific"
	sed -i '/specific>/,/\/specific>*/d' $pfd && echo "已删除 specific 与 /specific 区间行"
	sed -i '/\/specificScene/ r specific' $pfd && rm -rf $TMPDIR/specific && echo "已写回Oplus相机 specific"
	sed -i '/^[ \t]*$/d' $pfd && rm -rf specific && echo "已删除空行"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' $pfd && echo "已关闭温控锁帧率"
sed -i 's/cpu=\".*\" g/cpu=\"-1\" g/g' $pfd && echo "CPU -1"
sed -i 's/gpu=\".*\" r/gpu=\"-1\" r/g' $pfd && echo "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' $pfd && echo "相机亮度 255"
	sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' $pfd && echo "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB "
	echo "修改 realme GT模式高温控制器文件完成"
else
	echo " ✘ 不存在 realme GT模式高温控制器文件：$src_stcc_gt" >&2
fi
}
if [ -z $src_stcc_gt ];then
echo "未定义 realme GT模式高温控制器 文件"
else
FNCNstcc_gt
fi

echo2n
function FNCNshtp(){
if [ -f $src_shtp ];then
	mountPfd $src_shtp
	echo "－开始编辑ColorOS 高温保护文件：$src_shtp"
	sed -i 's/HighTemperatureProtectSwitch>true/HighTemperatureProtectSwitch>false/g' $pfd && echo "已禁用ColorOS 高温保护"
	sed -i 's/HighTemperatureShutdownSwitch>true/HighTemperatureShutdownSwitch>false/g' $pfd && echo "已禁用高温关机"
	sed -i 's/HighTemperatureFirstStepSwitch>true/HighTemperatureFirstStepSwitch>false/g' $pfd && echo "已禁用高温第一步骤"
	sed -i 's/HighTemperatureDisableFlashSwitch>true/HighTemperatureDisableFlashSwitch>false/g' $pfd && echo "已关闭高温禁用手电"
	sed -i 's/HighTemperatureDisableFlashChargeSwitch>true/HighTemperatureDisableFlashChargeSwitch>false/g' $pfd && echo "已关闭高温禁用闪充，充就完了"
	sed -i 's/HighTemperatureControlVideoRecordSwitch>true/HighTemperatureControlVideoRecordSwitch>false/g' $pfd && echo "已关闭高温视频录制控制"
	sed -i -e '/HighTemperatureShutdownUpdateTime/d' -e '/HighTemperatureProtectFirstStepIn/d' -e '/HighTemperatureProtectFirstStepOut/d' -e '/HighTemperatureProtectThresholdIn/d' -e '/HighTemperatureProtectThresholdOut/d' -e '/HighTemperatureProtectShutDown/d' -e '/HighTemperatureDisableFlashLimit/d' -e '/HighTemperatureEnableFlashLimit/d' -e '/HighTemperatureDisableFlashChargeLimit/d' -e '/HighTemperatureEnableFlashChargeLimit/d' -e '/HighTemperatureDisableVideoRecordLimit/d' -e '/HighTemperatureEnableVideoRecordLimit/d' $pfd && echo "已删除部分 Time In/Out Dis/Enable 项"
	sed -i 's/camera_temperature_limit>[0-9]*</camera_temperature_limit>600</g' $pfd && echo "已修改camera_temperature_limit为600"
	sed -i 's/ToleranceFirstStepIn>[0-9]*</ToleranceFirstStepIn>600</g' $pfd && echo "已修改ToleranceFirstStepIn为600"
	sed -i 's/ToleranceFirstStepOut>[0-9]*</ToleranceFirstStepOut>580</g' $pfd && echo "已修改ToleranceFirstStepOut为580"
	sed -i 's/ToleranceSecondStepIn>[0-9]*</ToleranceSecondStepIn>620</g' $pfd && echo "已修改ToleranceSecondStepIn为620"
	sed -i 's/ToleranceSecondStepOut>[0-9]*</ToleranceSecondStepOut>600</g' $pfd && echo "已修改ToleranceSecondStepOut为600"
	sed -i 's/ToleranceStart>[0-9]*</ToleranceStart>540</g' $pfd && echo "已修改ToleranceStart为540"
	sed -i 's/ToleranceStop>[0-9]*</ToleranceStop>520</g' $pfd && echo "已修改ToleranceStop为520"
	blMv
	echo "修改ColorOS 高温保护文件完成"
	echo -e "请避免手机长时间处于高温状态（约44+℃）\n－高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"
else
	echo " ✘ 不存在ColorOS 高温保护文件：$src_shtp" >&2
fi
}
if [ -z $src_shtp ];then
echo "未定义 ColorOS 高温保护 文件"
else
FNCNshtp
fi

echo2n
function FNCNstc(){
if [ -f $src_stc ];then
	mountPfd $src_stc
	echo "－开始编辑ColorOS 温控文件：$src_stc"
	sed -i 's/is_upload_dcs>1/is_upload_dcs>0/g' $pfd && echo "已关闭上传dcs"
	sed -i 's/is_upload_log>11/is_upload_log>0/g' $pfd && echo "已关闭上传log"
	sed -i 's/is_upload_errlog>11/is_upload_errlog>0/g' $pfd && echo "已关闭上传错误log"
	sed -i 's/thermal_battery_temp>1/thermal_battery_temp>0/g' $pfd && echo "已关闭thermal_battery_temp"
	sed -i '/thermal_heat_path/d' $pfd && echo "已删除thermal_heat_path"
	# OPPO Find X3 <detect_environment_time_threshold>600000</detect_environment_time_threshold> <detect_environment_temp_threshold>30</detect_environment_temp_threshold>
	sed -i '/detect_environment_time_threshold>[0-9]*</d' $pfd && echo "已删除环境检测时间阈值"
	sed -i '/detect_environment_temp_threshold>[0-9]*</d' $pfd && echo "已删除环境检测温度阈值"
	sed -i 's/more_heat_threshold>[0-9]*</more_heat_threshold>600</g' $pfd && echo "已修改more_heat_threshold为600"
	sed -i 's/<heat_threshold>[0-9]*</<heat_threshold>580</g' $pfd && echo "已修改heat_threshold为580"
	sed -i 's/less_heat_threshold>[0-9]*</less_heat_threshold>560</g' $pfd && echo "已修改less_heat_threshold为560"
	sed -i 's/preheat_threshold>[0-9]*</preheat_threshold>540</g' $pfd && echo "已修改preheat_threshold为540"
	sed -i 's/preheat_dex_oat_threshold>[0-9]*</preheat_dex_oat_threshold>520</g' $pfd && echo "已修改preheat_dex_oat_threshold为520"
	blMv
	echo "修改ColorOS 温控文件完成"
	echo -e "请避免手机长时间处于高温状态（约44+℃）\n－高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"
else
	echo " ✘ 不存在ColorOS 温控文件：$src_stc" >&2
fi
}
if [ -z $src_stc ];then
echo "未定义 ColorOS 温控 文件"
else
FNCNstc
fi

echo2n
if [ -d $src_horae ];then
echo "－检测到存在加密温控目录，尝试模块替换为空"
REPLACE="
/system/system_ext/etc/horae
"
else
echo "未定义 加密温控 目录"
fi

echo2n
if [[ $switch_thermal == TRUE ]];then
echo "－开始编辑修改温控节点温度阈值"
for thermalTemp in `find /sys/devices/virtual/thermal/ -iname "*temp*" -type f`
do
	wint=$(cat $thermalTemp)
	[[ -z $wint ]] && continue
	echo "$(realpath $thermalTemp) 当前参数：$wint" >&2
	alias echoTt=echo "改善参数：$(cat $pfd) 到$(realpath $thermalTemp)"
[[ $wint -lt 40000 || $wint -ge 55000 ]] && echo " ✘ 跳过修改" && continue
	mountPfd $thermalTemp
	if [ $wint -lt 45000 ];then
		echo 45000 >$pfd
		echoTt
		# chown -h adb.adb $pfd
	elif [ $wint lt 55000 ];then
	# 假如默认参数大于等于45℃并且小于55℃，就改成55℃
		echo 55000 >$pfd
		echoTt
	# elif [ $wint -lt 65000 ];then
		# echo 65000 >$pfd
		# echoTt
	# elif [ $wint -lt 75000 ];then
		# echo 75000 >$pfd
		# echoTt
	# elif [ $wint -lt 85000 ];then
		# echo 85000 >$pfd
		# echoTt
	# elif [ $wint -lt 95000 ];then
		# echo 95000 >$pfd
		# echoTt
	# elif [ $wint -lt 105000 ];then
		# echo 105000 >$pfd
		# echoTt
	fi
done
echo "修改温控节点温度阈值完成"
else
echo " ✘ 开关已关闭，跳过修改温度阈值"
fi

# find /system /vendor /product /odm /system_ext -type f -iname "*thermal*" -exec ls -s -h {} \; 2>/dev/null | sed '/hardware/d' ; # swap to 0, may cause STUCK.

echo2n
function FNCNapn() {
if [ -f $src_apn ];then
	mountPfd $src_apn
	echo "－开始编辑ColorOS 自带APN接入点配置文件：$src_apn"
	sed -i '/read_only/s/true/false/g' $pfd && echo "已关闭自带接入点修改限制"
	blMv
	echo "修改ColorOS 自带APN接入点配置文件完成"
else
	echo " ✘ 不存在ColorOS 自带APN接入点配置文件：$src_apn " >&2
fi
}
if [ -z $src_apn ];then
echo "未定义 ColorOS 自带APN接入点配置 文件"
else
FNCNapn
fi

echo2n
if [ ! -z "$list_hybridswap" ];then
	echo "－尝试在安装有面具的情况下开启内存拓展"
	# ColorOS 和 realmeUI 内存拓展管理脚本为 '/product/bin/init.oplus.nandswap.sh'
	resetprop persist.sys.oplus.nandswap.condition true
	echo 1 >/sys/block/zram0/hybridswap_dev_life
else
	echo "跳过了激活内存拓展"
	echo 3 >$MODPATH/hybridswap_sign
fi

echo2n
function FNCNsmac(){
if [ -f $src_smac ];then
	mountPfd $src_smac
	echo "－开始编辑ColorOS 应用分身/App Cloner 配置文件：$src_smac"
	sed -i 's/maxNum name="[0-9]*/maxNum name="999/' $pfd && echo "已修改应用分身数量限制改为 999"
	echo "－开始添加应用到allowed列表"
	for APKN in $APKNs
	do
	multiAPKN="<item\ name\=\"$APKN\"\ \/>"
		if [[ -z "$(grep "$multiAPKN" $pfd)" ]];then
			sed -i '/<allowed>/a'"$multiAPKN" $pfd && echo "已新添加App包名：$APKN 到应用分身允许名单" >&2
		else
			echo "包名：$APKN 已在应用分身名单" >&2
		fi
	done
	blMv
	echo "修改ColorOS 应用分身/App Cloner 配置文件完成"
fi
}
if [ -z $src_smac ];then
echo "未定义 应用分身/App Cloner 文件"
else
FNCNsmac
fi


echo "



######### 以下编辑 /data/ 目录内文件 #########"

echo2n
function FNCNblacklistMv(){
if [ -f $src_blacklistMv ];then
	mountPfd $src_blacklistMv
	echo "－开始编辑ColorOS 启动管理文件：$src_blacklistMv"
	for APKN in $blacklistAPKNs
	do
		if [[ -z $(grep "$APKN" $pfd) ]];then
			sleep 0
		else
			echo "检索到含有黑名单应用包名：$APKN 的行" >&2
			sed -i '/'$APKN'/d' $pfd && echo "－已删除↑" >&2
		fi
	done
	blMv
	echo "修改ColorOS 启动管理文件完成"
fi
}
if [ -z $src_blacklistMv ];then
echo "未定义 启动管理 文件"
else
FNCNblacklistMv
fi

echo2n
function FNCNblacklistMv3c(){
if [ -f $src_blacklistMv3c ];then
	mountPfd $src_blacklistMv3c
	echo "－开始编辑ColorOS 系统启动V3配置表：$src_blacklistMv3c"
	for APKN in $blacklistAPKNs
	do
		if [[ -z $(grep "$APKN" $pfd) ]];then
			sleep 0
		else
			echo "检索到含有黑名单应用包名：$APKN 的行" >&2
			sed -i '/'$APKN'/d' $pfd && echo "－已删除↑" >&2
		fi
	done
	blMv
	echo "修改ColorOS 系统启动V3配置表完成"
fi
}
if [ -z $src_blacklistMv3c ];then
echo "未定义 系统启动V3配置表 文件"
else
FNCNblacklistMv3c
fi

echo2n
if [ -z $src_bootwhitelist ];then
echo "未定义 ColorOS 12 自启动白名单 或 ColorOS 13 自启动允许名单文件 文件"
else
apknAdd $src_bootwhitelist "ColorOS 12 自启动白名单 或 ColorOS 13 自启动允许名单文件"
fi

echo2n
if [ -z $src_acwl ];then
echo "未定义 关联启动白名单 文件"
else
apknAdd $src_acwl "ColorOS 关联启动白名单"
fi

echo2n
if [ -z $src12_bootallow ];then
echo -e "未定义 自启动允许名单 文件。\n可能的原因分别有：①注释了定义变量，②安卓13 设备，不存在bootallow.txt"
else
apknAdd $src12_bootallow "ColorOS 12 自启动允许应用名单"
fi

echo2n
if [ -z $src13_awl ];then
echo -e "未定义ColorOS 13 自启动白名单文件 文件。\n可能的原因分别有：①注释了定义变量，②安卓12 设备"
else
apknAdd $src13_awl "ColorOS 13 自启动白名单文件"
fi

echo2n
function FNCNbgApp(){
if [ -f $src_bgApp ];then
	mountPfd $src_bgApp
	echo "－开始编辑ColorOS Oplus桌面的锁定后台数量限制文件：$src_bgApp"
	sed -i '/lock_app_limit/ s/value="[0-9]*/value="999/' $pfd && echo "已修改锁定后台数量限制为 999"
	echo "修改ColorOS Oplus桌面的锁定后台数量限制文件完成"
else
	echo " ✘ 不存在ColorOS Oplus桌面的锁定后台数量限制文件：$src_bgApp" >&2
fi
}
if [ -z $src_bgApp ];then
echo "未定义 锁定后台数量 文件"
else
FNCNbgApp
fi

echo2n
function FNCNspea(){
if [ -f $src_spea ];then
	mountPfd $src_spea
	echo "－开始编辑ColorOS 支付安全保护名单文件：$src_spea"
	sed -i 's/protectapp.*protectapp>/protectapp \/>/g' $pfd && echo "已清空配置文件<protectapp />标签"
	echo "修改ColorOS 支付安全保护名单完成"
	echo "请自行注意网络、ROOT权限应用等环境的安全性！谨防上当受骗！"
else
	echo " ✘ 不存在ColorOS 支付安全保护名单文件：$src_spea" >&2
fi
}
if [ -z $src_spea ];then
echo "未定义 支付安全保护名单 文件"
else
FNCNspea
fi

echo2n
function FNCNsdmtam(){
if [ -f $src_sdmtam ];then
	mountPfd $src_sdmtam
	echo "－开始编辑ColorOS 暗色模式第三方应用管理名单文件：$src_sdmtam"
	for APKN in $APKNs
	do
		darkAPKN="<p\ attr\=\"$APKN\"\/>"
		if [[ -z "$(grep "$darkAPKN" $pfd)" ]];then
			sed -i '/<\/filter-conf>/i'"$darkAPKN" $pfd && echo "已新添加APP包名：$APKN 到三方应用暗色名单" >&2
		else
			echo "包名：$APKN 已在暗色模式第三方应用管理名单" >&2
		fi
	done
	echo "修改ColorOS 暗色模式第三方应用管理名单完成"
	echo "“三方应用暗色”可以将自身不支持暗色的应用调整为适合暗色模式下使用的效果。部分应用开启后可能会出现显示异常。"
fi
}
if [ -z $src_sdmtam ];then
echo "未定义 暗色模式第三方应用管理名单 文件"
else
FNCNsdmtam
fi


# 注释掉多余挂载命令行
sed -i 's/^mount --bind \$MODDIR\/system\//# mount --bind \$MODDIR\/system\//g' $pfds
# 清理临时文件
rm -rf $MODPATH/dts_configs >/dev/null 2>&1

echo "

－模块安装完成
修改在重启后生效
	^ω^
"


set_perm_recursive $MODPATH 0 0 0755 0644

