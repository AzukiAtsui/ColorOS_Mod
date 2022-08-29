#
# Copyright (C) 2022 AzukiAtsui
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This file is part of ColorOS_Mod;
# repo: https://github.com/AzukiAtsui/ColorOS_Mod

SKIPUNZIP=1
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2


if [[ -e /data/adb/modules/coloros_mod/post-fs-data.sh ]];then
sed -n 's/^mount --bind .* \//umount \//g;p' /data/adb/modules/coloros_mod/post-fs-data.sh >$TMPDIR/umount.sh
. $TMPDIR/umount.sh
fi



appPackagesName=$(pm list packages -e -3 | sed 's/.*://')
# 黑名单应用包名，在编辑自启名单环节将其删除
blacklistAppPackagesName="
com.xunmeng.pinduoduo
com.nearme.instant.platform
"

pfds=$MODPATH/post-fs-data.sh
echo "MODDIR=\${0%/*}" >$pfds




echoBoundary() {
	sleep 1
	echo -e '\n\n'
}


mountPfd() {
	pfdDir=$(dirname $1 | sed -e 's/^\/vendor\//\/system\/vendor\//' -e 's/^\/product\//\/system\/product\//' -e 's/^\/system_ext\//\/system\/system_ext\//')
	[[ -d $MODPATH$pfdDir ]] || mkdir -p $MODPATH$pfdDir
	# echo "将复制文件 $1 到模块后修改"
	cp -rf $1 $MODPATH$pfdDir
	pfd=$MODPATH$pfdDir/${1##*/}
		if [[ -e $pfd ]];then
			echo "mount --bind \$MODDIR$pfdDir/${1##*/} $1" >>$pfds
		else
			echo " ✘ 找不到需编辑的文件" >&2
			return 1
		fi
}




# 高刷新率
source_rrc=/my_product/etc/refresh_rate_config.xml
if [[ -e $source_rrc ]];then
	mountPfd $source_rrc
	echo " - 开始编辑ColorOS 屏幕刷新率应用配置文件：$source_rrc "
	sed -i 's/rateId=\"[0-9]-[0-9]-[0-9]-[0-9]/rateId=\"3-1-2-3/g' $pfd || echo "修改高刷名单失败"
	sed -i 's/enableRateOverride=\"true/enableRateOverride=\"false/g' $pfd && echo "surfaceview，texture场景不降"
	sed -i 's/disableViewOverride=\"true/disableViewOverride=\"false/g' $pfd && echo "已关闭disableViewOverride"
	sed -i 's/inputMethodLowRate=\"true/inputMethodLowRate=\"false/g' $pfd && echo "已关闭输入法降帧"
	echo "修改ColorOS 应用刷新率重点应用名单完成，未在名单内应用享受系统设置刷新率"
else
	echo "不存在ColorOS 屏幕刷新率应用配置文件"
fi


echoBoundary
# 动态刷新率(adfr)
source_ovc=/my_product/etc/oplus_vrr_config.json
if [[ -e $source_ovc ]];then
	mountPfd $source_ovc
	echo " - 开始编辑ColorOS 动态刷新率(adfr)文件：$source_ovc"
	sed -i '/\"blacklist\"/,/[\s\S]*\s*\]/d' $pfd && echo "已删除黑名单"
	sed -i -e '/"timeout": [0-9]*,/d' -e '/"hw_brightness_limit": [0-9]*,/d' -e '/"hw_gray": true,/d' -e '/"hw_gray_threshold": [0-9]*,/d' -e '/"hw_gray_percent": [0-9]*,/d' $pfd && echo "已删除多余内容"
	echo "修改ColorOS 动态刷新率(adfr)对应的文件完成"
else
	echo "不存在ColorOS 动态刷新率(adfr)对应的文件"
fi


echoBoundary
# 视频锁帧
source_mdpl=/my_product/vendor/etc/multimedia_display_perf_list.xml
if [[ -e $source_mdpl ]];then
	mountPfd $source_mdpl
	echo " - 开始编辑ColorOS 视频播放器帧率控制文件：$source_mdpl"
	sed -i -e '/<fps>/d' -e '/<vsync>/d' $pfd && echo "已删除锁帧、垂直同步设置"
	echo "修改ColorOS 视频播放器帧率控制文件完成"
	echo "设置120hz时，播放视频可120hz。"
else
	echo "不存在ColorOS 视频播放器帧率控制文件"
fi


echoBoundary
# 去除 realme 非GT模式游戏锁帧率等限制
source_stcc=/odm/etc/temperature_profile/sys_thermal_control_config.xml
if [[ -e $source_stcc ]];then
	mountPfd $source_stcc
	echo " - 开始编辑ColorOS 高温控制器文件：$source_stcc"
	sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' $pfd >$TMPDIR/specificScene && echoRgb "已备份腾讯QQ specificScene"
	sed -i '/specificScene/,/\/specificScene/d' $pfd && echo "已删除 specificScene 与 /specificScene 区间行"
	sed -i '/\/screenOff/ r specificScene' $pfd && rm -rf $TMPDIR/specificScene && echo "已写回腾讯QQ specificScene"
	sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' $pfd >$TMPDIR/specific && echoRgb "已备份Oplus相机 specific"
	sed -i '/specific>/,/\/specific>*/d' $pfd && echo "已删除 specific 与 /specific 区间行"
	sed -i '/\/specificScene/ r specific' $pfd && rm -rf $TMPDIR/specific && echo "已写回Oplus相机 specific"
	sed -i '/^[  ]*$/d' $pfd && rm -rf specific && echo "已删除空行"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' $pfd && echo "已关闭温控锁帧率"
sed -i 's/cpu=\".*\" g/cpu=\"-1\" g/g' $pfd && echo "CPU -1"
sed -i 's/gpu=\".*\" r/gpu=\"-1\" r/g' $pfd && echo "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' $pfd && echo "相机亮度 255"
	sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' $pfd && echo "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB "
	echo "修改ColorOS 温控控制器文件完成"
	echo "ColorOS 温控锁帧及其它限制已解除。"
else
	echo "不存在ColorOS 高温控制器文件"
fi


echoBoundary
# 去除 realme GT模式游戏锁帧率: fps="0; 修改GPU、CPU为 -1 ; 限制 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 后面的值都改成0
source_stcc_gt=/odm/etc/temperature_profile/sys_thermal_control_config_gt.xml
if [[ -e $source_stcc_gt ]];then
	mountPfd $source_stcc_gt
	echo " - 开始编辑 realme GT模式温控控制器文件：$source_stcc_gt"
	sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' $pfd >$TMPDIR/specificScene && echoRgb "已备份腾讯QQ specificScene"
	sed -i '/specificScene/,/\/specificScene/d' $pfd && echo "已删除 specificScene 与 /specificScene 区间行"
	sed -i '/\/screenOff/ r specificScene' $pfd && rm -rf $TMPDIR/specificScene && echo "已写回腾讯QQ specificScene"
	sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' $pfd >$TMPDIR/specific && echoRgb "已备份Oplus相机 specific"
	sed -i '/specific>/,/\/specific>*/d' $pfd && echo "已删除 specific 与 /specific 区间行"
	sed -i '/\/specificScene/ r specific' $pfd && rm -rf $TMPDIR/specific && echo "已写回Oplus相机 specific"
	sed -i '/^[  ]*$/d' $pfd && rm -rf specific && echo "已删除空行"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' $pfd && echo "已关闭温控锁帧率"
sed -i 's/cpu=\".*\" g/cpu=\"-1\" g/g' $pfd && echo "CPU -1"
sed -i 's/gpu=\".*\" r/gpu=\"-1\" r/g' $pfd && echo "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' $pfd && echo "相机亮度 255"
	sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' $pfd && echo "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB "
	echo "修改 realme GT模式温控控制器文件完成"
	echo "GT模式温控锁帧及其它限制已解除"
else
	echo "不存在 realme GT模式高温控制器文件"
fi


echoBoundary
# 修改温控 高温保护
source_shtp=/odm/etc/temperature_profile/$(for i in /odm/etc/temperature_profile/sys_high_temp_protect*.xml;do echo ${i##*/};done)
if [[ -e $source_shtp ]];then
	mountPfd $source_shtp
	echo " - 开始编辑ColorOS 高温保护文件：$source_shtp"
	sed -i 's/HighTemperatureProtectSwitch>true/HighTemperatureProtectSwitch>false/g' $pfd && echo "已禁用ColorOS 高温保护"
	sed -i -e 's/HighTemperatureShutdownSwitch>true/HighTemperatureShutdownSwitch>false/g' $pfd && echo "已禁用高温关机"
	sed -i -e 's/HighTemperatureFirstStepSwitch>true/HighTemperatureFirstStepSwitch>false/g' $pfd && echo "已禁用第一步"
	sed -i -e 's/HighTemperatureDisableFlashSwitch>true/HighTemperatureDisableFlashSwitch>false/g' $pfd && echo "已关闭高温禁用手电"
	sed -i -e 's/HighTemperatureDisableFlashChargeSwitch>true/HighTemperatureDisableFlashChargeSwitch>false/g' $pfd && echo "已关闭高温禁用闪充，充就完了"
	sed -i -e 's/HighTemperatureControlVideoRecordSwitch>true/HighTemperatureControlVideoRecordSwitch>false/g' $pfd && echo "已关闭高温视频录制控制"
	sed -i -e '/HighTemperatureShutdownUpdateTime/d' -e '/HighTemperatureProtectFirstStepIn/d' -e '/HighTemperatureProtectFirstStepOut/d' -e '/HighTemperatureProtectThresholdIn/d' -e '/HighTemperatureProtectThresholdOut/d' -e '/HighTemperatureProtectShutDown/d' -e '/HighTemperatureDisableFlashLimit/d' -e '/HighTemperatureEnableFlashLimit/d' -e '/HighTemperatureDisableFlashChargeLimit/d' -e '/HighTemperatureEnableFlashChargeLimit/d' -e '/HighTemperatureDisableVideoRecordLimit/d' -e '/HighTemperatureEnableVideoRecordLimit/d' $pfd && echo "已删除部分 Time In/Out Dis/Enable 项"
	sed -i 's/camera_temperature_limit>[0-9]*</camera_temperature_limit>600</g' $pfd && echo "已修改camera_temperature_limit为600"
	sed -i 's/ToleranceFirstStepIn>[0-9]*</ToleranceFirstStepIn>600</g' $pfd && echo "已修改ToleranceFirstStepIn为600"
	sed -i 's/ToleranceFirstStepOut>[0-9]*</ToleranceFirstStepOut>580</g' $pfd && echo "已修改ToleranceFirstStepOut为580"
	sed -i 's/ToleranceSecondStepIn>[0-9]*</ToleranceSecondStepIn>620</g' $pfd && echo "已修改ToleranceSecondStepIn为620"
	sed -i 's/ToleranceSecondStepOut>[0-9]*</ToleranceSecondStepOut>600</g' $pfd && echo "已修改ToleranceSecondStepOut为600"
	sed -i 's/ToleranceStart>[0-9]*</ToleranceStart>540</g' $pfd && echo "已修改ToleranceStart为540"
	sed -i 's/ToleranceStop>[0-9]*</ToleranceStop>520</g' $pfd && echo "已修改ToleranceStop为520"
	echo "修改ColorOS 高温保护文件完成"
	echo "请避免手机长时间处于高温状态（约44+℃）\n - 高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"
else
	echo "不存在ColorOS 高温保护文件"
fi


echoBoundary
# 修改温控
source_stc=/odm/etc/ThermalServiceConfig/sys_thermal_config.xml
if [[ -e $source_stc ]];then
	mountPfd $source_stc
	echo " - 开始编辑ColorOS 温控文件：$source_stc"
	sed -i 's/is_upload_dcs>1/is_upload_dcs>0/g' $pfd && echo "已关闭is_upload_dcs"
	sed -i 's/thermal_battery_temp>1/thermal_battery_temp>0/g' $pfd && echo "已关闭thermal_battery_temp"
	sed -i '/thermal_heat_path/d' $pfd && echo "已删除thermal_heat_path"
	sed -i -e '/<\!--/d' $pfd && echo "已删除注释行"
	sed -i 's/more_heat_threshold>[0-9]*</more_heat_threshold>600</g' $pfd && echo "已修改more_heat_threshold为600"
	sed -i 's/<heat_threshold>[0-9]*</<heat_threshold>580</g' $pfd && echo "已修改heat_threshold为580"
	sed -i 's/less_heat_threshold>[0-9]*</less_heat_threshold>560</g' $pfd && echo "已修改less_heat_threshold为560"
	sed -i 's/preheat_threshold>[0-9]*</preheat_threshold>540</g' $pfd && echo "已修改preheat_threshold为540"
	sed -i 's/preheat_dex_oat_threshold>[0-9]*</preheat_dex_oat_threshold>520</g' $pfd && echo "已修改preheat_dex_oat_threshold为520"
	echo "修改ColorOS 温控文件完成"
	echo "请避免手机长时间处于高温状态（约44+℃）\n - 高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！"
else
	echo "不存在ColorOS 温控文件"
fi


# 删除加密温控
if [[ -d /system_ext/etc/horae ]];then
echo " - 检测到存在加密温控目录，尝试模块替换为空"
REPLACE="
/system/system_ext/etc/horae
"
fi


echoBoundary
# 应用分身/应用双开 OnePlus 9 Pro: /system_ext/oppo/sys_multi_app_config.xml ; realme GT Neo2: /system_ext/oplus/sys_multi_app_config.xml
# source_smac=$(find /system /system_ext -type f -iname sys_multi_app_config.xml | sed 1n )
for source_smac in /system_ext/oppo/sys_multi_app_config.xml /system_ext/oplus/sys_multi_app_config.xml
do
if [[ -e $source_smac ]];then
	mountPfd $source_smac
	echo " - 开始编辑ColorOS 12 应用分身/应用双开配置文件：$source_smac"
	sed -i 's/maxNum name="[0-9]*/maxNum name="999/' $pfd && echo "已修改应用分身数量限制改为 999"
	echo " - 开始添加应用到allowed列表"
	for appPakageName in $appPackagesName
	do
	multiAppPakageName="<item name=\"$appPakageName\" />"
		if [[ -z $(grep "$multiAppPakageName" $pfd) ]];then
			sed -i '/<allowed>/a'"$multiAppPakageName" $pfd && echo "已新添加APP包名：$appPakageName 到应用分身允许名单"
		else
			echo "包名：$appPakageName 已在应用分身名单"
		fi
	done
	echo "修改ColorOS 12 应用分身/应用双开 配置文件完成"
fi
done


echoBoundary
echo " - 开始编辑修改温控节点温度阈值"
for thermalTemp in `find /sys/devices/virtual/thermal/ -iname "*temp*" -type f`
do
    echo $(realpath $thermalTemp)
    wint=`cat $thermalTemp`
    echo "默认参数：$wint"
    [[ $wint -lt 40000 || $wint -ge 55000 ]] && echo " ✘ 跳过修改" && continue
    mountPfd $thermalTemp
    if [[ $wint -ge 40000 && $wint -lt 45000 ]];then
        echo 45000 > $pfd
        echo "改善参数：`cat $pfd`"
        # chown -h adb.adb $pfd
    elif [[ $wint -ge 45000 && $wint -lt 55000 ]];then
    # 假如默认参数大于等于45℃并且小于55℃，就改成55℃
        echo 55000 > $pfd
        echo "改善参数：`cat $pfd`"
    # elif [[ $wint -ge 55000 && $wint -lt 65000 ]];then
        # echo 65000 > $pfd
        # echo "改善参数：`cat $pfd`"
    # elif [[ $wint -ge 65000 && $wint -lt 75000 ]];then
        # echo 75000 > $pfd
        # echo "改善参数：`cat $pfd`"
    # elif [[ $wint -ge 75000 && $wint -lt 85000 ]];then
        # echo 85000 > $pfd
        # echo "改善参数：`cat $pfd`"
    # elif [[ $wint -ge 85000 && $wint -lt 95000 ]];then
        # echo 95000 > $pfd
        # echo "改善参数：`cat $pfd`"
    # elif [[ $wint -ge 95000 && $wint -lt 105000 ]];then
        # echo 105000 > $pfd
        # echo "改善参数：`cat $pfd`"
    fi
done
echo "修改温控节点温度阈值完成"


echoBoundary


echoBoundary
echo "######### 以下为 /data 目录编辑 #########"


echoBoundary
# 自启白名单 OnePlus 9 Pro ColoOS12: /data/oppo/coloros/startup/bootwhitelist.txt ; realme GT Neo2 UI 3.0 Android 12: /data/oplus/os/startup/bootwhitelist.txt ; # 系统推荐开机自启的app包名。不在bootwhitelist.txt中的app会占用不推荐自启的名额。
for source_bootwhitelist in /data/oppo/coloros/startup/bootwhitelist.txt /data/oplus/os/startup/bootwhitelist.txt
do
if [[ -e $source_bootwhitelist ]];then
	mountPfd $source_bootwhitelist
	echo " - 开始编辑ColorOS 12 自启白名单：$source_bootwhitelist"
	for appPakageName in $appPackagesName
	do
		sed -i '/'$appPakageName'$/d' $pfd
		sed -i '$a'$appPakageName $pfd && echo "已去重添加包名：$appPakageName 到自启白名单"
	done
	for appPakageName in $blacklistAppPackagesName
	do
		sed -i '/'$appPakageName'$/d' $pfd && echo " - 已从名单删除黑名单应用 包名：$appPakageName"
	done
	echo "修改ColorOS 12 自启白名单文件完成"
fi
done


echoBoundary
# 开机自启允许名单 OnePlus 9 Pro: /data/oppo/coloros/startup/bootallow.txt ; realme GT Neo2: /data/oplus/os/startup/bootallow.txt
for source_bootallow in /data/oppo/coloros/startup/bootallow.txt /data/oplus/os/startup/bootallow.txt
do
if [[ -e $source_bootallow ]];then
	mountPfd $source_bootallow
	echo " - 开始编辑ColorOS 12 开机自启允许名单文件：$source_bootallow"
	for appPakageName in $appPackagesName
	do
		sed -i '/'$appPakageName'$/d' $pfd
		sed -i '$a'$appPakageName $pfd && echo "已去重添加包名：$appPakageName 到开机自启允许名单"
	done
	for appPakageName in $blacklistAppPackagesName
	do
		sed -i '/'$appPakageName'$/d' $pfd && echo " - 已从名单删除黑名单应用 包名：$appPakageName"
	done
	echo "修改ColorOS 12 开机自启允许应用名单文件完成"
	echo "不在 自启白名单(bootwhitelist.txt) 中的app 会占用“不推荐自启”的名额。"
fi
done


echoBoundary
# 最近任务管理可锁定数量
source_bgApp=/data/user_de/0/com.android.launcher/shared_prefs/Configuration.xml
if [[ -e $source_bgApp ]];then
	mountPfd $source_bgApp
	echo " - 开始编辑ColorOS 12 Oplus桌面的锁定后台数量限制文件：$source_bgApp"
	sed -i '/lock_app_limit/ s/value="[0-9]*/value="999/' $pfd && echo "已修改锁定后台数量限制为 999"
	echo "修改ColorOS 12 Oplus桌面的锁定后台数量限制文件完成"
else
	echo "不存在ColorOS 12 Oplus桌面的锁定后台数量限制文件"
fi


echoBoundary
# 禁用ROOT后打开支付软件时的报毒，需要禁用支付安全环境扫描，可以在系统设置里面手动关闭；
source_spea=/data/data/com.coloros.securepay/files/enabledapp.xml
if [[ -e $source_spea ]];then
	mountPfd $source_spea
	echo " - 开始编辑ColorOS 支付安全保护名单文件：$source_spea"
	sed -i 's/protectapp.*protectapp>/protectapp \/>/g' $pfd && echo "已清空配置文件<protectapp />标签"
	echo "修改ColorOS 支付安全保护名单完成"
	echo "请自行注意网络、ROOT权限应用等环境的安全性！谨防上当受骗！"
else
	echo "不存在ColorOS 支付安全保护名单文件"
fi


echoBoundary
# 第三方应用暗色模式文件位置 realme GT Neo2 Android 12：/data/oplus/os/darkmode/sys_dark_mode_third_app_managed.xml ;
# OnePlus 9 Pro ColorOS 12：/data/oppo/coloros/darkmode/sys_dark_mode_third_app_managed.xml ; # 其中记录了可以强制启用深色模式的app包名，添加应用保存即可，不用重启
for source_sdmtam in /data/oplus/os/darkmode/sys_dark_mode_third_app_managed.xml /data/oppo/coloros/darkmode/sys_dark_mode_third_app_managed.xml
do
if [[ -e $source_sdmtam ]];then
	mountPfd $source_sdmtam
	echo " - 开始编辑ColorOS 暗色模式第三方应用管理名单文件：$source_sdmtam"
	for appPakageName in $appPackagesName
	do
		darkAppPakageName="<p attr=\"$appPakageName\"/>"
		if [[ -z $(grep "$darkAppPakageName" $pfd) ]];then
			sed -i '/<\/filter-conf>/ i'"$darkAppPakageName" $pfd && echo "已新添加APP包名：$appPakageName 到三方应用暗色名单"
		else
			echo "包名：$appPakageName 已在暗色模式第三方应用管理名单"
		fi
	done
	echo "修改ColorOS 暗色模式第三方应用管理名单完成"
	echo "“三方应用暗色”可以将自身不支持暗色的应用调整为适合暗色模式下使用的效果。部分应用开启后可能会出现显示异常。"
fi
done


# 删除多余挂载命令行
sed -i '/MODDIR\/system\//d' $pfds


echoBoundary
echo "
 - 模块安装完成
修改在重启后生效
"


set_perm_recursive $MODPATH 0 0 0755 0644
# by AzukiAtsui 2022-08-28