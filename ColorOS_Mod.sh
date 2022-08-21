#
# Copyright (C) 2022 酷安@灼热的红豆
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

# shell script by 酷安@灼热的红豆;
# e-mail address: AzukiAtsui@163.com

echoRgb() {
	#转换echo颜色提高可读性
	if [[ $2 = 0 ]]; then
		echo -e "\e[38;5;197m - $1\e[0m"
	elif [[ $2 = 1 ]]; then
		echo -e "\e[38;5;121m - $1\e[0m"
	else
		echo -e "\e[38;5;214m - $1\e[0m"
	fi
}

abort() {
echoRgb "$1" "0"
exit 1
}

if [ "$(whoami)" != root ]; then
	abort "你是憨批？不给Root用你妈！爬！"
fi

######### 机制说明 #########
#
## source_file 源文件; target_file “热更新”文件 (即 /data/system/${source_file##*/}); source_file_edited 为复制源文件到可读写目录，此脚本默认为 ./test 文件。
# mv -f $source_file_edited $target_file; # 系统自动对比 /data/system/目录下同名文件 与底层分区内同名文件的时间，使用更新的文件参数。
# 推荐在升级系统后重跑此脚本 或 使用 magisk模块 在每次开机时自动执行此脚本（$MODPATH/service.sh)
#
## mount --bind $target_file $source_file; # Linux 常用的挂载只读目录下文件的方法，对于dir挂载只生效同名文件，umount $target_file 为取消挂载。
#
######### by 酷安@灼热的红豆 #########

ds=/data/system

# 高刷新率
source_rrc=/my_product/etc/refresh_rate_config.xml
target_rrc=$ds/refresh_rate_config.xml
if [[ -e $source_rrc ]]
then
echo " - 开始编辑ColorOS 屏幕刷新率应用配置文件：$source_rrc 并将其“热更新”到$target_rrc"
cp -rf $source_rrc ./test
sed -i 's/rateId=\"[0-9]-[0-9]-[0-9]-[0-9]/rateId=\"3-1-2-3/g' ./test || echoRgb "修改高刷名单失败" 0
# sed -i 's/enableRateOverride=\"true/enableRateOverride=\"false/g' ./test && echoRgb "surfaceview，texture场景不降"
sed -i 's/disableViewOverride=\"true/disableViewOverride=\"false/g' ./test && echoRgb "已关闭disableViewOverride"
sed -i 's/inputMethodLowRate=\"true/inputMethodLowRate=\"false/g' ./test && echoRgb "已关闭输入法降帧"
mv -f ./test $target_rrc
chmod 444 $target_rrc
echoRgb "修改ColorOS 应用刷新率重点应用名单完成，未在名单内应用享受系统设置刷新率" "1"
else
  echoRgb "不存在ColorOS 屏幕刷新率应用配置文件" "0"
fi


sleep 1
echo ''; # 输出一个空行，使用 两个单引号 '' 方便检索
# 动态刷新率(adfr)
source_ovc=/my_product/etc/oplus_vrr_config.json
target_ovc=$ds/oplus_vrr_config.json
if [[ -e $source_ovc ]]
then
echo " - 开始编辑ColorOS 动态刷新率(adfr)文件：$source_ovc 并将其“热更新”到$target_ovc"
cp -rf $source_ovc ./test
# sed '/address_start_line/,/address_end_line/ d ' ; # 区间行
sed -i '/\"blacklist\"/,/[\s\S]*\s*\]/d' ./test && echoRgb "已删除黑名单"
sed -i -e '/"timeout": [0-9]*,/d'  -e '/"hw_brightness_limit": [0-9]*,/d'  -e '/"hw_gray": true,/d'  -e '/"hw_gray_threshold": [0-9]*,/d'  -e '/"hw_gray_percent": [0-9]*,/d' ./test && echoRgb "已删除多余内容"
mv -f ./test $target_ovc
chmod 444 $target_ovc
echoRgb "修改ColorOS 动态刷新率(adfr)对应的文件完成" "1"
else
  echoRgb "不存在ColorOS 动态刷新率(adfr)对应的文件" "0"
fi


sleep 1
echo ''
# 视频锁帧
source_mdpl=/my_product/vendor/etc/multimedia_display_perf_list.xml
target_mdpl=$ds/multimedia_display_perf_list.xml
target_mdpl_1=/data/vendor/multimedia_display_perf_list.xml
if [[ -e $source_mdpl ]]
then
echo " - 开始编辑ColorOS 视频播放器帧率控制文件：$source_mdpl 并将其“热更新”到$target_mdpl 和$target_mdpl_1"
cp -rf $source_mdpl ./test
sed -i -e '/<fps>/d' -e '/<vsync>/d' ./test && echoRgb "已删除锁帧、垂直同步设置"
cp -f ./test $target_mdpl_1
mv -f ./test $target_mdpl
chmod 444 $target_mdpl
echoRgb "修改ColorOS 视频播放器帧率控制文件完成" "1"
echoRgb "设置120hz时，播放视频可120hz。" "1"
else
  echoRgb "不存在ColorOS 视频播放器帧率控制文件" "0"
fi


sleep 1
echo ''
# 去除 realme 非GT模式游戏锁帧率等限制
source_stcc=/odm/etc/temperature_profile/sys_thermal_control_config.xml
target_stcc=$ds/sys_thermal_control_config.xml
if [[ -e $source_stcc ]]
then
echo " - 开始编辑ColorOS 高温控制器文件：$source_stcc 并将其“热更新”到$target_stcc"
cp -rf $source_stcc ./test
# sed -n '/com\.tencent\.mobileqq_103/=' ./test | sed -n "2"p ; # 输出第二次匹配行号
sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' ./test >./specificScene && echoRgb "已备份腾讯QQ specificScene"
sed -i '/specificScene/,/\/specificScene/d' ./test && echoRgb "已删除 specificScene 与 /specificScene 区间行"
sed -i '/\/screenOff/ r specificScene' ./test && rm -rf specificScene &&  echoRgb "已写回腾讯QQ specificScene" "1"
sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' ./test >./specific && echoRgb "已备份相机 specific"
sed -i '/specific>/,/\/specific>*/d' ./test && echoRgb "已删除 specific 与 /specific 区间行"
sed -i '/\/specificScene/ r specific' ./test && rm -rf specific && echoRgb "已写回Oplus相机 specific" "1"
sed -i '/^[  ]*$/d' ./test && rm -rf specific && echoRgb "已删除空行"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' ./test && echoRgb "已关闭温控锁帧率"
sed -i 's/cpu=\".*\" g/cpu=\"-1\" g/g' ./test && echoRgb "CPU -1"
sed -i 's/gpu=\".*\" r/gpu=\"-1\" r/g' ./test && echoRgb "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' ./test && echoRgb "相机亮度 255"
sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' ./test && echoRgb "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB "
mv -f ./test $target_stcc
chmod 444 $target_stcc
echoRgb "修改ColorOS 温控控制器文件完成" "1"
echoRgb "ColorOS 温控锁帧及其它限制已解除。" "1"
else
  echoRgb "不存在ColorOS 高温控制器文件" "0"
fi


sleep 1
echo ''
# 去除 realme GT模式游戏锁帧率 fps="0; 修改GPU、CPU为 -1 ; 限制 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 后面的值都改成0
source_stcc_gt=/odm/etc/temperature_profile/sys_thermal_control_config_gt.xml
target_stcc_gt=$ds/sys_thermal_control_config_gt.xml
if [[ -e $source_stcc_gt ]]
then
echo " - 开始编辑 realme GT模式温控控制器文件：$source_stcc_gt 并将其“热更新”到$target_stcc_gt"
cp -rf $source_stcc_gt ./test
sed -n -e '/specificScene/p' -e '/com\.tencent\.mobileqq_103/,/com.tencent.mobileqq_103/p' ./test >./specificScene && echoRgb "已备份腾讯QQ specificScene"
sed -i '/specificScene/,/\/specificScene/d' ./test && echoRgb "已删除 specificScene 与 /specificScene 区间行"
sed -i '/\/screenOff/ r specificScene' ./test && rm -rf specificScene &&  echoRgb "已写回腾讯QQ specificScene" "1"
sed -n -e '/specific>/p' -e '/com\.oplus\.camera>/,/com\.oplus\.camera>/p' ./test >./specific && echoRgb "已备份Oplus相机 specific"
sed -i '/specific>/,/\/specific>*/d' ./test && echoRgb "已删除 specific 与 /specific 区间行"
sed -i '/\/specificScene/ r specific' ./test && rm -rf specific && echoRgb "已写回Oplus相机 specific" "1"
sed -i '/^[  ]*$/d' ./test && rm -rf specific && echoRgb "已删除空行"
sed -i 's/fps=\"[0-9]*/fps=\"0/g' ./test && echoRgb "已关闭温控锁帧率"
sed -i 's/cpu=\".*\" g/cpu=\"-1\" g/g' ./test && echoRgb "CPU -1"
sed -i 's/gpu=\".*\" r/gpu=\"-1\" r/g' ./test && echoRgb "GPU -1"
sed -i 's/cameraBrightness=\"[0-9]*/cameraBrightness=\"255/g' ./test && echoRgb "相机亮度 255"
sed -i -e 's/restrict=\"[0-9]*/restrict=\"0/g' -e 's/brightness=\"[0-9]*/brightness=\"0/g' -e 's/charge=\"[0-9]*/charge=\"0/g' -e 's/modem=\"[0-9]*/modem=\"0/g' -e 's/disFlashlight=\"[0-9]*/disFlashlight=\"0/g' -e 's/stopCameraVideo=\"[0-9]*/stopCameraVideo=\"0/g' -e 's/disCamera=\"[0-9]*/disCamera=\"0/g' -e 's/disWifiHotSpot=\"[0-9]*/disWifiHotSpot=\"0/g' -e 's/disTorch=\"[0-9]*/disTorch=\"0/g' -e 's/disFrameInsert=\"[0-9]*/disFrameInsert=\"0/g' -e 's/refreshRate=\"[0-9]*/refreshRate=\"0/g' -e 's/disVideoSR=\"[0-9]*/disVideoSR=\"0/g' -e 's/disOSIE=\"[0-9]*/disOSIE=\"0/g' -e 's/disHBMHB=\"[0-9]*/disHBMHB=\"0/g' ./test && echoRgb "已关闭部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB "
mv -f ./test $target_stcc_gt
chmod 444 $target_stcc_gt
echoRgb "修改 realme GT模式温控控制器文件完成" "1"
echoRgb "GT模式温控锁帧及其它限制已解除" "1"
else
  echoRgb "不存在 realme GT模式高温控制器文件" "0"
fi


sleep 1
echo ''
opset="/data/data/com.miHoYo.Yuanshen/shared_prefs/com.miHoYo.Yuanshen.v2.playerprefs.xml"
if [[ -e $opset ]]
then
  a=$(pm dump com.miHoYo.Yuanshen | grep "versionName");
  a=${a#*=};
  a=${a%.*};
  b=$(echo "$a >= 2.7" | bc)
    case $b in
      1)
        echoRgb "原神v2.7 版本以后改配置不能解锁90 FPS" "0"
        ;;
      0)
          cp -rf $opset ./test
          sed -i 's/A7%2C%5C%22value%5C%22%3A0/A7%2C%5C%22value%5C%22%3A2/g' ./test || echoRgb "修改失败 呜呜呜" "0"
          mv -f ./test $opset
          chmod 440 $opset
          chmod 551 ${opset%/*}
          echoRgb "修改原神配置文件成功 :-)" "1"
          echoRgb "手机须全局高刷才能触发！"
          ;;
    esac
else
    echoRgb "未安装原神，已跳过解锁原神90 FPS" "1"
fi


sleep 1
echo ''
# 修改温控 高温保护
source_shtp=/odm/etc/temperature_profile/$(for i in /odm/etc/temperature_profile/sys_high_temp_protect*.xml;do echo ${i##*/};done)
target_shtp=$ds/${source_shtp##*/}
if [[ -e $source_shtp ]]
then
echo " - 开始编辑ColorOS 高温保护文件：$source_shtp 并将其“热更新”到$target_shtp"
cp -rf $source_shtp ./test
sed -i 's/HighTemperatureProtectSwitch>true/HighTemperatureProtectSwitch>false/g' ./test && echoRgb "已禁用ColorOS 高温保护"
sed -i -e 's/HighTemperatureShutdownSwitch>true/HighTemperatureShutdownSwitch>false/g' ./test && echoRgb "已禁用高温关机"
sed -i -e 's/HighTemperatureFirstStepSwitch>true/HighTemperatureFirstStepSwitch>false/g' ./test && echoRgb "已禁用第一步"
sed -i -e 's/HighTemperatureDisableFlashSwitch>true/HighTemperatureDisableFlashSwitch>false/g' ./test && echoRgb "已关闭高温禁用手电"
sed -i -e 's/HighTemperatureDisableFlashChargeSwitch>true/HighTemperatureDisableFlashChargeSwitch>false/g' ./test && echoRgb "已关闭高温禁用闪充，充就完了"
sed -i -e 's/HighTemperatureControlVideoRecordSwitch>true/HighTemperatureControlVideoRecordSwitch>false/g' ./test && echoRgb "已关闭高温视频录制控制"
# 删除
  sed -i -e '/HighTemperatureShutdownUpdateTime/d' -e '/HighTemperatureProtectFirstStepIn/d' -e '/HighTemperatureProtectFirstStepOut/d' -e '/HighTemperatureProtectThresholdIn/d' -e '/HighTemperatureProtectThresholdOut/d' -e '/HighTemperatureProtectShutDown/d' -e '/HighTemperatureDisableFlashLimit/d' -e '/HighTemperatureEnableFlashLimit/d' -e '/HighTemperatureDisableFlashChargeLimit/d' -e '/HighTemperatureEnableFlashChargeLimit/d' -e '/HighTemperatureDisableVideoRecordLimit/d' -e '/HighTemperatureEnableVideoRecordLimit/d' ./test && echoRgb "已删除部分 Time In/Out Dis/Enable 项"
# 修改数值
    sed -i 's/camera_temperature_limit>[0-9]*</camera_temperature_limit>600</g' ./test && echoRgb "已修改camera_temperature_limit为600"
    sed -i 's/ToleranceFirstStepIn>[0-9]*</ToleranceFirstStepIn>600</g' ./test && echoRgb "已修改ToleranceFirstStepIn为600"
    sed -i 's/ToleranceFirstStepOut>[0-9]*</ToleranceFirstStepOut>580</g' ./test && echoRgb "已修改ToleranceFirstStepOut为580"
    sed -i 's/ToleranceSecondStepIn>[0-9]*</ToleranceSecondStepIn>620</g' ./test && echoRgb "已修改ToleranceSecondStepIn为620"
    sed -i 's/ToleranceSecondStepOut>[0-9]*</ToleranceSecondStepOut>600</g' ./test && echoRgb "已修改ToleranceSecondStepOut为600"
    sed -i 's/ToleranceStart>[0-9]*</ToleranceStart>540</g' ./test && echoRgb "已修改ToleranceStart为540"
    sed -i 's/ToleranceStop>[0-9]*</ToleranceStop>520</g' ./test && echoRgb "已修改ToleranceStop为520"
# 省事方案
# sed -i 's/isOpen>1</isOpen>0</g' ./test && echoRgb "已关闭高温保护机制"
# sed -i '/switch/,/[0-9]/d' ./test && echoRgb "已删除各高温保护机制行"
mv -f ./test $target_shtp
chmod 444 $target_shtp
echoRgb "修改ColorOS 高温保护文件完成" "1"
echoRgb "请避免手机长时间处于高温状态（约44+℃）\n - 高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！" "0"
else
  echoRgb "不存在ColorOS 高温保护文件" "0"
fi


sleep 1
echo ''
# 修改温控
source_stc=/odm/etc/ThermalServiceConfig/sys_thermal_config.xml
target_stc=$ds/${source_stc##*/}
if [[ -e $source_stc ]]
then
echo " - 开始编辑ColorOS 温控文件：$source_stc 并将其“热更新”到$target_stc"
cp -rf $source_stc ./test
sed -i 's/is_upload_dcs>1/is_upload_dcs>0/g' ./test && echoRgb "已关闭is_upload_dcs"
sed -i 's/thermal_battery_temp>1/thermal_battery_temp>0/g' ./test && echoRgb "已关闭thermal_battery_temp"
# 删除
  sed -i '/thermal_heat_path/d' ./test && echoRgb "已删除thermal_heat_path"; # thermal_heat_path>/sys/class/thermal/thermal_zone49/temp
  sed -i -e '/<\!--/d' ./test && echoRgb "已删除注释行"
# 修改数值
    sed -i 's/more_heat_threshold>[0-9]*</more_heat_threshold>600</g' ./test && echoRgb "已修改more_heat_threshold为600"
    sed -i 's/<heat_threshold>[0-9]*</<heat_threshold>580</g' ./test && echoRgb "已修改heat_threshold为580"
    sed -i 's/less_heat_threshold>[0-9]*</less_heat_threshold>560</g' ./test && echoRgb "已修改less_heat_threshold为560"
    sed -i 's/preheat_threshold>[0-9]*</preheat_threshold>540</g' ./test && echoRgb "已修改preheat_threshold为540"
    sed -i 's/preheat_dex_oat_threshold>[0-9]*</preheat_dex_oat_threshold>520</g' ./test && echoRgb "已修改preheat_dex_oat_threshold为520"
# 省事方案
# sed -i 's/isOpen>1</isOpen>0</g' ./test && echoRgb "已关闭温控机制"
# sed -i '/more/,/[0-9]/d' ./test && echoRgb "已删除温控机制行"
mv -f ./test $target_stc
chmod 444 $target_stc
echoRgb "修改ColorOS 温控文件完成" "1"
echoRgb "请避免手机长时间处于高温状态（约44+℃）\n - 高温可加速电池去世，甚至导致手机故障、主板损坏、火灾等危害！" "0"
else
  echoRgb "不存在ColorOS 温控文件" "0"
fi


# /system_ext/etc/horae还有一部分加密温控文件


# 应用分身/应用双开 OnePlus 9 Pro: /system_ext/oppo/sys_multi_app_config.xml 
# 应用分身/应用双开 realme GT Neo2: /system/system_ext/oplus/sys_multi_app_config.xml 
sleep 1
echo ''
# 应用分身数量限制改为 999
# source_smac=$(find /system /system_ext -type file -iname sys_multi_app_config.xml)
for source_smac in /system_ext/oppo/sys_multi_app_config.xml /system_ext/oplus/sys_multi_app_config.xml
do
if [[ -e $source_smac ]]
then
target_smac=/data/system/sys_multi_app_config.xml
if [[ -e $source_smac ]]
then
echo " - 开始编辑ColorOS 12 应用分身/应用双开配置文件：$source_smac 并将其“热更新”到$target_smac"
cp -rf $source_smac ./test
sed -i 's/maxNum name="[0-9]*/maxNum name="999/' ./test && echoRgb "已修改应用分身数量限制改为 999"
mv -f ./test $target_smac
chmod 444 $target_smac
echoRgb "修改ColorOS 12 应用分身/应用双开 配置文件完成" "1"
else
  echoRgb "不存在ColorOS 12  应用分身配置文件" "0"
fi
fi
done




######### 以下为 /data 目录编辑 #########
## bak_file 备份可读写目录下的配置文件，默认"${source_file}.bak"
sleep 1
echo ''
# 开机自启允许名单 OnePlus 9 Pro: /data/oppo/coloros/startup/bootallow.txt ; realme GT Neo2: /data/oplus/os/startup/bootallow.txt
for source_bootallow in /data/oppo/coloros/startup/bootallow.txt /data/oplus/os/startup/bootallow.txt
do
bak_bootallow="${source_bootallow}.bak"
if [[ -e $source_bootallow ]]
then
echo " - 开始编辑ColorOS 12 开启自启应用名单文件：$source_bootallow 并创建其备份文件：$bak_bootallow"
cp -rf $source_bootallow $bak_bootallow
cp -rf $source_bootallow ./test
## 交互式输入应用包名
# read -p "输入应用包名：" appPakageName
# read -p "输入应用名称：" appName
# regexAppPakageName="$(echo "$appPakageName" | sed -n 's/\./\\&/g;p')"
# echo -e "新建测试文件\nAzukiAtsui" >./test
# if [[ -z $(grep $appPakageName ./test) ]];then
# sed -i '$a\'$regexAppPakageName ./test && echo "已允许APP: $appName 包名：$appPakageName 开机自启"
# else; echo "名单内已存在的应用包名：$appPakageName";fi
sed -i '$ a \com\.omarea\.vtools' ./test && echoRgb "已允许APP: Scene5 开机自启"
mv -f ./test $source_bootallow
chmod 700 $source_bootallow
echoRgb "修改ColorOS 12 开启自启应用名单文件完成" "1"
echoRgb "不在 自启白名单(bootwhitelist.txt) 中的app会占用“不推荐自启”的名额。" "0"
fi
done


# 自启白名单 OnePlus 9 Pro ColoOS12: /data/oppo/coloros/startup/bootwhitelist.txt ; realme GT Neo2 UI 3.0 Android 12: /data/oplus/os/startup/bootwhitelist.txt ; # 系统推荐开机自启的app包名。不在bootwhitelist.txt中的app会占用不推荐自启的名额。 


# 锁定后台数量限制  后台锁定由Oplus桌面来管理 /data/user_de/0/com.android.launcher/shared_prefs/Configuration.xml
sleep 1
echo ''
# 锁定后台数量限制改为 999
source_bgApp=/data/user_de/0/com.android.launcher/shared_prefs/Configuration.xml
bak_bgApp="${source_bgApp}.bak"
if [[ -e $source_bgApp ]]
then
echo " - 开始编辑ColorOS 12 Oplus桌面的锁定后台数量限制文件：$source_bgApp 并创建其备份文件：$bak_bgApp"
cp -rf $source_bgApp $bak_bgApp
cp -rf $source_bgApp ./test
sed -i '/lock_app_limit/ s/value="[0-9]*/value="999/' ./test && echoRgb "已修改锁定后台数量限制为 999"
mv -f ./test $source_bgApp
chmod 444 $source_bgApp
echoRgb "修改ColorOS 12 Oplus桌面的锁定后台数量限制文件完成" "1"
echoRgb "此项在重启后生效" "0"
else
  echoRgb "不存在ColorOS 12 Oplus桌面的锁定后台数量限制文件" "0"
fi


# 禁用打开支付软件时的报毒，需要禁用支付安全环境扫描，可以在系统设置里面手动关闭。
# 文件是/data/data/com.coloros.securepay/files/enabledapp.xml，直接打开文件，把<protectapp />标签清空
# chmod 440 /data/data/com.coloros.securepay/files/enabledapp.xml


# realme GT Neo2 Android 12 深色模式文件位置更新为：/data/oplus/os/darkmode/sys_dark_mode_third_app_managed.xml 
# OnePlus 9 Pro ColorOS 12 深色模式文件位置更新为：/data/oppo/coloros/darkmode/sys_dark_mode_third_app_managed.xml ; # 其中记录了可以强制启用深色模式的app包名，添加应用保存即可，不用重启 




re_bak() {
mv -f $1 ${1%.*}
}
if [[ $chkRec = 1 ]]
then
rm -f $target_smac $target_stc $target_shtp $target_stcc_gt $target_stcc $target_mdpl $target_ovc $target_rrc
re_bak $bak_bootallow
re_bak $bak_bgApp
fi


echoRgb "\n\n\n - 运行完成" "0"
echoRgb "运行完成" "1"
echoRgb "运行完成" ""
echoRgb "部分修改在重启手机后生效"

# Thanks to Anharmony@coolapk, 咸鱼C@coolapk, JasonLiao@coolapk. 
# by AzukiAtsui 2022-08-21