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

SKIPUNZIP=1
# 欧加设备 国家/地区代码
nvid=`getprop ro.build.oplus_nv_id`
[ -z $nvid ] && abort "当前系统不是ColorOS 或者 realmeUI，不必使用ColorOS_Mod"
# 各安卓平台版本所支持的 API 级别见 [Android 开发者指南](https://developer.android.com/guide/topics/manifest/uses-sdk-element#ApiLevels) 
if [ $API -le 30 ];then abort "不支持Android 11 及以下。仅对Android 12 ~ 13 的ColorOS 和 realmeUI 生效"
elif [ $API -lt 33 ];then echo " 你好，安卓12 用户。 ❛‿˂̵✧"
elif [ $API -eq 33 ];then echo " 你好，安卓13 用户。 (＾Ｕ＾)ノ~";fi
unzip -o "$ZIPFILE" -x 'META-INF/*' customize.sh -d $MODPATH >&2

# 安装前，在模块目录/switches.sh 确认修改的文件
source $MODPATH/switches.sh
# 如果只想取消对文件的部分修改，
# 在更下方的“开始编辑配置文件”的 sed 命令行前加井号。

# 载入白名单  允许自启
source $MODPATH/whitelist
# 载入黑名单应用包名  禁止自启
source $MODPATH/blacklist

function chkNvid(){
case $nvid in
	10010111) echo CN 中国 China;;
	00011010) echo TW 中国台湾省 Taiwan;;
	00110111) echo RU 俄罗斯 Russia;;
	01000100) echo GDPR 欧盟 EU;;
	10001101) echo GDPR 欧洲 Europe;;
	00011011) echo GDPR 欧洲 Europe;;
	00011011) echo IN 印度 India;;
	00110011) echo ID 印度尼西亚 Indonesia;;
	00111000) echo MY 马来西亚 Malaysia;;
	00111001) echo TH 泰国 Thailand;;
	00111110) echo PH 菲律宾 Philippines;;
	10000011) echo SA 沙特阿拉伯 Saudi Arabia;;
	10011010) echo LATAM 拉丁美洲 Latin America;;
	10011110) echo BR 巴西 Brazil;;
	10100110) echo MEA 中东和非洲 The Middle East and Africa;;
	*) echo "当前国家/地区代码 = $nvid";;
esac
}

[[ $(date "+%H%M") -lt 600 || $(date "+%H%M") -gt 2200 ]] && echo "当前系统时间 $(date "+%Y-%m-%d %H:%M:%S")，应该休息！"
product_model=`getprop ro.product.model` # 20221002, value of ro.product.name is diffrent to ro.product.model in ColorOS for OnePlus; but they are same in realmeUI.
ota_version=`getprop ro.build.version.ota`
rui_version=`getprop ro.build.version.realmeui` # | sed 's/V//' | sed 's/\.0//'
# realme Q2 Pro CN ## ro.commonsoft.ota = ro.product.product.device = ro.product.device = RMX2175CN
# realme GT Neo2 CN ## ro.commonsoft.ota = ro.product.product.device = ro.product.device = RE5473 ; ro.separate.soft = 21619
# realme GT 2 Pro CN ## ro.separate.soft = 21631 ## ro.commonsoft.ota = RE547F = ro.product.device ; ro.product.product.device = ossi
product_id=`getprop ro.commonsoft.ota`
CODENAME=`cat /sys/firmware/devicetree/base/model | sed -n 's/.*[A-Z0-9][ ,]//;p'`
project_name=`getprop ro.separate.soft` # －项目 : `getprop ro.boot.prjname`
product_brand=`getprop ro.product.vendor.brand`
market_enname=`getprop ro.vendor.oplus.market.enname`
[ -z $market_enname ] && market_enname=`getprop ro.oppo.market.enname`

ui_print -e "\n\nColorOS_Mod-MagiskModule version : `grep_prop version $TMPDIR/module.prop`\n		versionCode : `grep_prop versioncode $TMPDIR/module.prop`"
ui_print "－** 设备信息 (DEVICE INFO) **"
ui_print "－品牌 (Brand) : $product_brand"
ui_print "－型号 (Model) : $product_model"
ui_print "－商品名 (Market Name) : `getprop ro.vendor.oplus.market.name`"
[ -z $market_enname ] || ui_print "－Market English Name : $market_enname"
ui_print "－设备码 (Device ID) : $product_id"
ui_print "－代号 (Codename) : $CODENAME"
ui_print "－项目 (Project Name) : $project_name"
ui_print "－地区 (Locale) : `getprop ro.product.locale`"
ui_print "－国家/地区 (Nation/Area) : `chkNvid`"
ui_print "－版本号（Build number） : `getprop ro.build.display.id`"
ui_print "－OTA版本 (OTA Version) : $ota_version"
ui_print "－ColorOS 版本 (ColorOS Version) : `getprop ro.build.version.oplusrom`"
[ -z $rui_version ] || ui_print "－realmeUI 版本 (realmeUI Version) : $rui_version"
ui_print "－基线版本 (Baseline) : `getprop ro.build.version.incremental`"
ui_print "－Android 版本 (Android Version) : `getprop ro.build.version.release`"
ui_print "－API level : $API"
ui_print "－SOC 型号 (SOC Model): `getprop ro.soc.model`"
ui_print "－CPU 架构 (CPU architecture) : $ARCH"
ui_print "－内核版本 (Kernel Version) : `uname -a`"
ui_print "－运存大小 (RAM/memory Info) : `free -m|grep "Mem"|awk '{print $2}'` MB ; 已用: `free -m|grep "Mem"|awk '{print $3}'` MB ; 剩余: $((`free -m|grep "Mem"|awk '{print $2}'`-`free -m|grep "Mem"|awk '{print $3}'`)) MB"
ui_print "－Swap大小 (Swap Info) : `free -m|grep "Swap"|awk '{print $2}'` MB ; 已用: `free -m|grep "Swap"|awk '{print $3}'` MB ; 剩余: `free -m|grep "Swap"|awk '{print $4}'` MB"

termuxBash=/data/user/0/com.termux/files/usr/bin/bash
mtBash=/data/user/0/bin.mt.plus/files/term/usr/bin/bash
if [ -f $MODPATH/bin/bash ];then echo "将使用模块内置的 GNU Bash"
elif [ -f $termuxBash ];then cp -rf $termuxBash $MODDIR/bin/bash;echo "尝试用 termux 内置的 bash"
elif [ -f $mtBash ];then cp -rf $mtBash $MODDIR/bin/bash;echo "尝试用 MT管理器 内置的 bash"
else abort "有时竟一个 bash 都没有！";fi
chmod +x $(find $MODPATH/bin)
export PATH="$MODPATH/bin":"$PATH"

damCM=/data/adb/modules/$(grep_prop id $TMPDIR/module.prop)
if [ -f $damCM/post-fs-data.sh ];then cat $damCM/post-fs-data.sh | grep 'mount --bind' | sed -n 's/^[# ]*mount --bind .* \//umount \//g;p' >$TMPDIR/umount.sh
	. $TMPDIR/umount.sh 2>/dev/null;fi


sn=1
echo2n() { echo -e "\n\nNo. $sn";sn=$(($sn+1));}

pfds=$MODPATH/post-fs-data.sh
mountPfd() {
	pfdDir=$(dirname $1 | sed -e 's/^\/vendor\//\/system\/vendor\//' -e 's/^\/product\//\/system\/product\//' -e 's/^\/system_ext\//\/system\/system_ext\//')
	[ -d $MODPATH$pfdDir ] || mkdir -p $MODPATH$pfdDir
	# echo "将复制文件 $1 到模块后修改"
	cp -rf $1 $MODPATH$pfdDir
	pfd=$MODPATH$pfdDir/${1##*/}
	if [ -f $pfd ];then echo "mount --bind \$MODDIR$pfdDir/${1##*/} $1" >>$pfds;else abort " ✘ 模块目录下竟然没有需编辑的 $pfd 文件，请联系开发者修复！";fi
}

apknAdd() {
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2：$1"
	for APKN in $APKNs;do sed -i '/'$APKN'$/d' $pfd;sed -i '$a'$APKN $pfd && echo "已去重添加包名：$APKN 到$2" >&2;done
	for APKN in $blacklistAPKNs;do sed -i '/'$APKN'$/d' $pfd && echo " ✘ 已从$2删除黑名单应用 包名：$APKN" >&2;done
	echo "修改$2完成";fi
}

blMv() {
	# 删除注释
	# sed -i '/^<\!--/,/-->$/c''' $pfd ;# 会错误地删除部分非注释
	sed -i 's/[[:space:]]*<\!--.*-->[[:space:]]*//g' $pfd
	# 删除空行
	sed -i '/^[[:space:]]*$/d' $pfd
}

chkFUN() { if [ -z $1 ];then echo "未定义 $2 文件";else $3 "$1" "$2";fi;}


echo -e "\n\n\n######### 开始修改配置文件 #########"

echo2n
if [[ $switch_dtbo == TRUE ]];then
	echo "－开始修改 dtbo镜像"
	echo "－Once dtbo or other critical partitions had been flashed, Android Verified Boot should be disabled by \`AVB_flag=3 bash ColorOS_Mod/avb.sh\` just in case RED STATE STUCK."
	if [ `cat $damCM/dtbo_sign` -eq 1 ];then echo " ✔ 已刷入过修改后的 dtbo";echo 1 >$MODPATH/dtbo_sign;fi
	bash $MODPATH/dts.sh >&2
	case $? in
		0) echo -e "大概是修改并刷入成功了\n欲知详情请保存安装日志（通常在右上角）\n请勿删除或移动 $damCM 目录的原版dtbo\n在将来，卸载 ColorOS_Mod 时会刷回原版 dtbo";;
		14) echo "dts配置文件丢失，模块损坏？";;
		13) echo "dtc二进制文件丢失，模块损坏？";;
		12) echo "mkdtimg二进制文件丢失，模块损坏？";;
		11) echo "bash二进制文件丢失，模块损坏？";;
		5) echo "这次没有改 dtbo，但可以继续下面的修改";;
	esac
else echo "开关已关闭，跳过修改 dtbo镜像";echo 3 >$MODPATH/dtbo_sign;fi

FUN_fccas() {
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i 's/<app_feature name=\"com.android.systemui.disable_fp_blind_unlock\"\/>//g' $pfd || abort "未知错误！请联系开发者修复！"
	sed -i '/<app_feature name\=\"com.android.systemui.enable_fp_blind_unlock\"\/>/d' -e '/<extend_features>/a <app_feature name=\"com.android.systemui.enable_fp_blind_unlock\"\/>' $pfd && echo "试图去除对息屏指纹盲解的禁用，可能有效"
	sed -i '/<app_feature name\=\"com.android.systemui.prevented_screen_burn\"\/>/d' -e '/<extend_features>/a <app_feature name="com.android.systemui.prevented_screen_burn"/>' $pfd && echo "<!-- indicate if the device is prevented screen burn -->"
	blMv
	echo "修改$2文件完成"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_fccas "ColorOS 13 系统设置延伸特性" FUN_fccas

FUN_rpref(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i -e '/<app_feature name=\"com.android.settings.move_dc_to_develop\"\/>/d' $pfd && echo "已删除移动DC调光到开发者选项设置"
	blMv
	echo -e "修改$2文件完成"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_rpref " realmeUI 系统设置延伸特性" FUN_rpref

FUN_rcc(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i 's/rateId=\"[0-9]-[0-9]-[0-9]-[0-9]/rateId=\"3-1-2-3/g' $pfd && echo "已全局改刷新率模式为 3-1-2-3"
	sed -i 's/enableRateOverride="true/enableRateOverride="false/g' $pfd && echo "surfaceview，texture场景不降"
	sed -i 's/disableViewOverride="true/disableViewOverride="false/g' $pfd && echo "已关闭disableViewOverride"
	sed -i 's/inputMethodLowRate="true/inputMethodLowRate="false/g' $pfd && echo "已关闭输入法降帧"
	blMv
	echo -e "修改$2完成\n注意：系统设置刷新率仍然生效"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_rrc "屏幕刷新率重点应用名单" FUN_rcc

FUN_ovc(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i '/\"blacklist\"/,/[\s\S]*\s*\]/d' $pfd && echo "已删除黑名单"
	sed -i -e '/"timeout": [0-9]*,/d' -e '/"hw_brightness_limit": [0-9]*,/d' -e '/"hw_gray": true,/d' -e '/"hw_gray_threshold": [0-9]*,/d' -e '/"hw_gray_percent": [0-9]*,/d' $pfd && echo "已删除多余内容"
	echo "修改$2文件完成"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
[ $product_brand == realme ] && chkFUN $src_ovc "动态刷新率(adfr) " FUN_ovc

FUN_mdpl(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i -e '/<fps>/d' -e '/<vsync>/d' $pfd && echo "已删除锁帧、垂直同步设置"
	blMv
	echo -e "修改$2文件完成\n设置120hz时，播放视频可120hz"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_mdpl "视频播放器帧率控制" FUN_mdpl

FUN_stcc(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' -e '/com.tencent.mm_scene_103-com.tencent.mobileqq_scene_103-com.whatsapp_scene_103/,/com.tencent.mm_scene_103-com.tencent.mobileqq_scene_103-com.whatsapp_scene_103/p' $pfd >$TMPDIR/specificScene && echo "已备份腾讯QQ 微信 WhatsApp specificScene"
	sed -i '/specificScene/,/\/specificScene/d' $pfd && echo "已删除 specificScene 与 /specificScene 区间行"
	sed -i '/\/screenOff/ r specificScene' $pfd && rm -rf $TMPDIR/specificScene && echo "已写回腾讯QQ specificScene"
	sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' $pfd >$TMPDIR/specific && echo "已备份Oplus相机 specific"
	sed -i '/specific>/,/\/specific>*/d' $pfd && echo "已删除 specific 与 /specific 区间行"
	sed -i '/\/specificScene/ r specific' $pfd && rm -rf $TMPDIR/specific && echo "已写回Oplus相机 specific"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' $pfd && echo "已关闭温控锁帧率"
sed -i 's/cpu=\"\-*[0-9]*/cpu=\"-1/g' $pfd && echo "CPU -1"
sed -i 's/gpu=\"\-*[0-9]*/gpu=\"-1/g' $pfd && echo "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' $pfd && echo "相机亮度 255"
	sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' $pfd && echo "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB"
	blMv
	echo "修改$2文件完成"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_stcc "系统高温控制配置" FUN_stcc

chkFUN $src_stcc_gt "realme GT模式高温控制器" FUN_stcc

FUN_shtp(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i '/HighTemperatureProtectSwitch>/s/true/false/g' $pfd && echo "已禁用$2"
	sed -i '/HighTemperatureShutdownSwitch>/s/true/false/g' $pfd && echo "已禁用高温关机"
	sed -i '/HighTemperatureFirstStepSwitch>/s/true/false/g' $pfd && echo "已禁用高温第一步骤"
	sed -i '/HighTemperatureDisableFlashSwitch>/s/true/false/g' $pfd && echo "已关闭高温禁用手电"
	sed -i '/HighTemperatureDisableFlashChargeSwitch>/s/true/false/g' $pfd && echo "已关闭高温禁用闪充，充就完了"
	sed -i '/HighTemperatureControlVideoRecordSwitch>/s/true/false/g' $pfd && echo "已关闭高温视频录制控制"
	sed -i -e '/HighTemperatureShutdownUpdateTime/d' -e '/HighTemperatureProtectFirstStepIn/d' -e '/HighTemperatureProtectFirstStepOut/d' -e '/HighTemperatureProtectThresholdIn/d' -e '/HighTemperatureProtectThresholdOut/d' -e '/HighTemperatureProtectShutDown/d' -e '/HighTemperatureDisableFlashLimit/d' -e '/HighTemperatureEnableFlashLimit/d' -e '/HighTemperatureDisableFlashChargeLimit/d' -e '/HighTemperatureEnableFlashChargeLimit/d' -e '/HighTemperatureDisableVideoRecordLimit/d' -e '/HighTemperatureEnableVideoRecordLimit/d' $pfd && echo "已删除部分 Time In/Out Dis/Enable 项"
	sed -i '/camera_temperature_limit>/s/>[0-9]*</>600</g' $pfd && echo "已修改camera_temperature_limit为600"
	sed -i '/ToleranceFirstStepIn>/s/>[0-9]*</>600</g' $pfd && echo "已修改ToleranceFirstStepIn为600"
	sed -i '/ToleranceFirstStepOut>/s/>[0-9]*</>580</g' $pfd && echo "已修改ToleranceFirstStepOut为580"
	sed -i '/ToleranceSecondStepIn>/s/>[0-9]*</>620</g' $pfd && echo "已修改ToleranceSecondStepIn为620"
	sed -i '/ToleranceSecondStepOut>/s/>[0-9]*</>600</g' $pfd && echo "已修改ToleranceSecondStepOut为600"
	sed -i '/ToleranceStart>/s/>[0-9]*</>540</g' $pfd && echo "已修改ToleranceStart为540"
	sed -i '/ToleranceStop>/s/>[0-9]*</>520</g' $pfd && echo "已修改ToleranceStop为520"
	blMv
	echo "修改$2文件完成"
	echo -e "请避免手机长时间处于高温状态（约44+℃）\n－高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_shtp "高温保护" FUN_shtp

FUN_stc(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i '/is_upload_dcs>/s/1/0/g' $pfd && echo "已关闭上传dcs"
	sed -i '/is_upload_log>/s/1/0/g' $pfd && echo "已关闭上传log"
	sed -i '/is_upload_errlog>/s/1/0/g' $pfd && echo "已关闭上传错误log"
	sed -i '/thermal_battery_temp>/s/1/0/g' $pfd && echo "已关闭thermal_battery_temp"
	sed -i '/thermal_heat_path/d' $pfd && echo "已删除thermal_heat_path"
	# OPPO Find X3 <detect_environment_time_threshold>600000</detect_environment_time_threshold> <detect_environment_temp_threshold>30</detect_environment_temp_threshold>
	sed -i '/detect_environment_time_threshold>[0-9]*</d' $pfd && echo "已删除环境检测时间阈值"
	sed -i '/detect_environment_temp_threshold>[0-9]*</d' $pfd && echo "已删除环境检测温度阈值"
	sed -i '/more_heat_threshold>/s/>[0-9]*</>600</g' $pfd && echo "已修改more_heat_threshold为600"
	sed -i '/<heat_threshold>/s/>[0-9]*</>580</g' $pfd && echo "已修改heat_threshold为580"
	sed -i '/less_heat_threshold>/s/>[0-9]*</>560</g' $pfd && echo "已修改less_heat_threshold为560"
	sed -i '/preheat_threshold>/s/>[0-9]*</>540</g' $pfd && echo "已修改preheat_threshold为540"
	sed -i '/preheat_dex_oat_threshold>/s/>[0-9]*</>520</g' $pfd && echo "已修改preheat_dex_oat_threshold为520"
	blMv
	echo "修改$2文件完成"
	echo -e "请避免手机长时间处于高温状态（约44+℃）\n－高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_stc "温控" FUN_stc

echo2n
if [ -d $src_horae ];then
echo "－检测到存在加密温控目录，尝试模块替换为空"
REPLACE="
/system/system_ext/etc/horae
"
else echo "未定义 加密温控 目录";fi

echo2n
if [[ $switch_thermal == TRUE ]];then
echo "－开始编辑修改温控节点温度阈值"
for thermalTemp in `find /sys/devices/virtual/thermal/ -iname "*temp*" -type f`;do wint=`cat $thermalTemp`
	[[ -z $wint ]] && continue
	echo "`realpath $thermalTemp` 当前参数：$wint" >&2
	alias echoTt=echo "改善参数：`cat $pfd` 到`realpath $thermalTemp`"
[[ $wint -lt 40000 || $wint -ge 55000 ]] && echo " ✘ 跳过修改" && continue
	mountPfd $thermalTemp
	if [ $wint -lt 45000 ];then echo 45000 >$pfd;echoTt
		# chown -h adb.adb $pfd
	elif [ $wint lt 55000 ];then
	# 假如默认参数大于等于45℃并且小于55℃，就改成55℃
		echo 55000 >$pfd;echoTt
	# elif [ $wint -lt 65000 ];then echo 65000 >$pfd;echoTt
	# elif [ $wint -lt 75000 ];then echo 75000 >$pfd;echoTt
	# elif [ $wint -lt 85000 ];then echo 85000 >$pfd;echoTt
	# elif [ $wint -lt 95000 ];then echo 95000 >$pfd;echoTt
	# elif [ $wint -lt 105000 ];then echo 105000 >$pfd;echoTt
	fi;done
echo "修改温控节点温度阈值完成"
else echo " ✘ 开关已关闭，跳过修改温度阈值";fi

# find /system /vendor /product /odm /system_ext -type f -iname "*thermal*" -exec ls -s -h {} \; 2>/dev/null | sed '/hardware/d' ; # swap to 0, may cause STUCK.

FUN_apn() {
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i '/read_only/s/true/false/g' $pfd && echo "已关闭自带接入点修改限制"
	blMv
	echo "修改$2文件完成"
else echo " ✘ 不存在$2文件：$1 " >&2;fi
}
chkFUN $src_apn "自带APN接入点配置" FUN_apn

echo2n
if [ ! -z "$list_hybridswap" ];then echo "－尝试在安装有面具的情况下开启内存拓展"
	# 欧加内存拓展管理脚本为 '/product/bin/init.oplus.nandswap.sh'
	resetprop persist.sys.oplus.nandswap.condition true
	echo 1 >/sys/block/zram0/hybridswap_dev_life
else echo "跳过了激活内存拓展";echo 3 >$MODPATH/hybridswap_sign;fi

FUN_smac(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i 's/maxNum name="[0-9]*/maxNum name="999/' $pfd && echo "已修改分身应用数量限制为 999"
	echo "－开始添加应用到$2允许名单"
	for APKN in $APKNs;do multiAPKN="<item\ name\=\"$APKN\"\ \/>"
		if [[ -z "$(grep "$multiAPKN" $pfd)" ]];then sed -i '/<allowed>/a'"$multiAPKN" $pfd && echo "已新添加App包名：$APKN 到$2允许名单" >&2
		else echo "包名：$APKN 已在$2名单" >&2;fi;done
	blMv
	sed -i '1i'"appClonerList=$damCM$pfdDir/${1##*/}" $MODPATH/service.sh
	echo "修改$2文件完成";fi
}
chkFUN $src_smac "应用分身配置（App cloner config）" FUN_smac

echo -e "\n\n\n\n######### 以下编辑 /data/ 目录内文件 #########"

FUN_blacklistMv(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	for APKN in $blacklistAPKNs;do
		if [[ -z $(grep "$APKN" $pfd) ]];then sleep 0
		else echo "检索到含有黑名单应用包名：$APKN 的行" >&2
			sed -i '/'$APKN'/d' $pfd && echo "－已删除↑" >&2;fi;done
	blMv
	echo "修改$2文件完成";fi
}
chkFUN $src_blacklistMv "启动管理" FUN_blacklistMv

chkFUN $src_blacklistMv3c "启动V3配置列表" FUN_blacklistMv

FUN_sdmtam(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	for APKN in $APKNs;do darkAPKN="<p\ attr\=\"$APKN\"\/>"
		if [[ -z "$(grep "$darkAPKN" $pfd)" ]];then sed -i '/<\/filter-conf>/i'"$darkAPKN" $pfd && echo "已新添加APP包名：$APKN 到$2" >&2
		else echo "包名：$APKN 已在$2" >&2;fi;done
	echo "修改$2完成"
	echo "“三方应用暗色”可以将自身不支持暗色的应用调整为适合暗色模式下使用的效果。部分应用开启后可能会出现显示异常。";fi
}
chkFUN $src_sdmtam "暗色模式第三方应用管理" FUN_sdmtam

chkFUN $src_bootwhitelist "ColorOS 12 自启动白名单 或 ColorOS 13 自启动允许名单文件" apknAdd

chkFUN $src_acwl "关联启动白名单" apknAdd;sed -i '1i'"associatedList=$damCM$pfdDir/${1##*/}" $MODPATH/service.sh

if [ -z $src12_bootallow ];then echo2n
echo -e "未定义 自启动允许 文件。\n可能的原因分别有：①注释了定义变量，②安卓13 设备，不存在bootallow.txt"
else apknAdd $src12_bootallow "ColorOS 12 自启动允许文件";fi

if [ -z $src13_awl ];then echo2n
echo -e "未定义ColorOS 13 自启动白名单文件 文件。\n可能的原因分别有：①注释了定义变量，②安卓12 设备"
else apknAdd $src13_awl "ColorOS 13 自启动白名单文件"
	sed -i '1i'"bootallow13List=$damCM$pfdDir/${1##*/}" $MODPATH/service.sh;fi

FUN_bgApp(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i '/lock_app_limit/s/value="[0-9]*/value="999/' $pfd && echo "已修改锁定后台数量限制为 999"
	echo "修改$2文件完成"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_bgApp "欧加桌面 (Oplus launcher) 配置" FUN_bgApp

FUN_spea(){
if [ -f $1 ];then mountPfd $1
echo2n
	echo "－开始编辑$2文件：$1"
	sed -i 's/protectapp.*protectapp>/protectapp \/>/g' $pfd && echo "已清空配置文件<protectapp />标签"
	echo "修改$2完成"
	echo "请自行注意网络、ROOT权限应用等环境的安全性！谨防上当受骗！"
else echo " ✘ 不存在$2文件：$1" >&2;fi
}
chkFUN $src_spea "安全支付的启用应用名单" FUN_spea

# 注释掉多余挂载命令行
sed -i 's/^mount --bind \$MODDIR\/system\//# mount --bind \$MODDIR\/system\//g' $pfds
# 清理临时文件
rm -rf $MODPATH/dts_configs >/dev/null 2>&1

ui_print -e "\n\n－模块安装完成\n修改在重启后生效\n	^ω^"

set_perm_recursive $MODPATH 0 0 0755 0644

