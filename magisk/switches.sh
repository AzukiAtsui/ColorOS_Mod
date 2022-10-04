# . $MODPATH/switches.sh

# 在不需要修改的文件变量定义命令行开头加 '#'（井号）
# 来在模块安装阶段跳过对它们的所有修改。
# 变量是指 '='（等号）前 src_*、switch_* 的英文。
# 例：
#	# [ -f $i ] && src_smac=$i

# dtbo镜像配置修改 ; 查看“dts_configs”和“模块安装日志”确认参数
switch_dtbo=TRUE
# realmeUI 需要内核解除 smart_charge 才能生效dtbo充电温控墙；感谢 酷安@init萌新很新

# ColorOS 13 系统设置延伸特性  例如：息屏指纹盲解
src_fccas=/my_product/etc/extension/feature_common_com.android.systemui.xml

# realmeUI 系统设置延伸特性
src_rpref=`find /my_product/etc/extension/ -type f -iname realme_product_rom_extend_feature_$(getprop ro.separate.soft).xml`

# 屏幕刷新率重点应用名单
src_rrc=/my_product/etc/refresh_rate_config.xml

# 动态刷新率(adfr)  221005 only for realme
src_ovc=/my_product/etc/oplus_vrr_config.json

# 视频播放器帧率控制
src_mdpl=/my_product/vendor/etc/multimedia_display_perf_list.xml

# 系统高温控制配置  去除ColorOS（realme 非GT模式）游戏锁帧率等限制（fps=0; 修改GPU、CPU为 -1 ; 严格(restrict) 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 后面的值都改成 0）
src_stcc=/odm/etc/temperature_profile/sys_thermal_control_config.xml

# 去除 realme GT模式游戏锁帧率，修改同上“系统高温控制配置”
src_stcc_gt=/odm/etc/temperature_profile/sys_thermal_control_config_gt.xml

# 高温保护
src_shtp=/odm/etc/temperature_profile/$(for i in /odm/etc/temperature_profile/sys_high_temp_protect*.xml;do echo ${i##*/};done)

# 温控
src_stc=/odm/etc/ThermalServiceConfig/sys_thermal_config.xml

# 加密温控
src_horae=/system_ext/etc/horae

# 温控节点温度阈值  off by default since v1.1.1 220921
# switch_thermal=TRUE

# 自带APN接入点配置  解除修改限制
src_apn=/system/product/etc/apns-conf.xml

# 内存拓展
list_hybridswap=$(ls -l /sys/block/zram0/hybridswap_* | grep ^'\-rw\-' | awk '{print $NF}')

# The config path of App cloner (应用分身) is same in Android 12 and Android 13.
for i in /system_ext/oppo/sys_multi_app_config.xml /system_ext/oplus/sys_multi_app_config.xml;do
	[ -f $i ] && src_smac=$i
	if [ -z $src_smac ];then
		echo " ✘ There is not the App cloner config file：$i" >&2
	else break;fi;done

# 启动管理  删除黑名单应用（blacklist文件中 blacklistAPKNs变量）
for i in /data/oppo/coloros/startup/startup_manager.xml /data/oplus/os/startup/startup_manager.xml;do
	[ -f $i ] && src_blacklistMv=$i
	if [ -z $src_blacklistMv ];then
		echo " ✘ 不存在欧加启动管理：$i" >&2
	else break;fi;done
# 启动V3配置列表  删除黑名单应用
for i in /data/oppo/coloros/startup/sys_startup_v3_config_list.xml /data/oplus/os/startup/sys_startup_v3_config_list.xml;do
	[ -f $i ] && src_blacklistMv3c=$i
	if [ -z $src_blacklistMv3c ];then
		echo " ✘ 不存在启动V3配置列表：$i" >&2
	else break;fi;done

# 暗色模式第三方应用管理  内含强制启用深色模式的App包名
for i in /data/oplus/os/darkmode/sys_dark_mode_third_app_managed.xml /data/oppo/coloros/darkmode/sys_dark_mode_third_app_managed.xml;do
	[ -f $i ] && src_sdmtam=$i
	if [ -z $src_sdmtam ];then
		echo " ✘ 不存在暗色模式第三方应用管理文件：$i" >&2
	else break;fi;done

# ColorOS 12 自启动白名单 系统推荐自启动的App包名列表 不在bootwhitelist.txt中的App占用不推荐自启的名额; Android 13 变为允许自启动而非推荐
for i in /data/oppo/coloros/startup/bootwhitelist.txt /data/oplus/os/startup/bootwhitelist.txt;do
	[ -f $i ] && src_bootwhitelist=$i
	if [ -z $src_bootwhitelist ];then
		echo " ✘ 不存在ColorOS 12 自启动白名单 或 ColorOS 13 自启动允许名单文件：$i" >&2
	else break;fi;done

# 关联启动白名单
for i in /data/oppo/coloros/startup/associate_white_list.txt /data/oplus/os/startup/associate_white_list.txt;do
	[ -f $i ] && src_acwl=$i
	if [ -z $src_acwl ];then
		echo " ✘ 不存在关联启动白名单：$i" >&2
	else break;fi;done

# 自启动允许 ColorOS 12
if [[ $API -lt 33 ]];then
	for i in /data/oppo/coloros/startup/bootallow.txt /data/oplus/os/startup/bootallow.txt;do
		[ -f $i ] && src12_bootallow="$i"
		if [ -z $src12_bootallow ];then
			echo " ✘ 不存在ColorOS 12 自启动允许文件：$i" >&2
		else break;fi;done;fi
# Android 13 版本
if [[ $API -eq 33 ]];then
	for i in /data/oppo/coloros/startup/autostart_white_list.txt /data/oplus/os/startup/autostart_white_list.txt;do
		[ -f $i ] && src13_awl="$i"
		if [ -z $src13_awl ];then
			echo " ✘ 不存在ColorOS 13 自启动白名单文件：$i" >&2
		else break;fi;done;fi

# 欧加桌面 (Oplus launcher) 配置  最近任务管理可锁定数量
src_bgApp=/data/user_de/0/com.android.launcher/shared_prefs/Configuration.xml

# 安全支付的启用应用名单  禁用ROOT后打开支付软件时的报毒，需要禁用支付安全环境扫描，可以在系统设置里面手动关闭
src_spea=/data/data/com.coloros.securepay/files/enabledapp.xml

