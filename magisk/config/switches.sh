FTF='find /data/oppo/coloros/startup/ /data/oplus/os/startup/ -type f -name';

# 在不需要修改的文件变量定义命令行开头加 '#'（井号）
# 来在模块安装阶段跳过对它们的所有修改。
# 变量是指 '='（等号）前 src_*、switch_* 的英文。
# 例：
#	# [ -f $i ] && src_smac=$i

# 以下将缩写 ColorOS 13 为 cos13，余各版本以此类推。
# 若在 realmeUI 和 cos 有同名文件，则只注 cos 版本，
# 否则注 rui 版本（rui2≈cos11; rui3≈cos12; rui4≈cos13）。
# 当文件在各版本的路径相同则不注明。

# dtbo镜像配置修改 ; 在 ColorOS_Mod.zip/config/dts 确认参数
switch_dtbo=TRUE

# splash/logo 开机第一屏镜像配置修改 ; 通常 ColorOS_Mod.zip/config/boot.bmp 是开机第一屏
# switch_splash=1

# =1 为启用时间显秒，=0 或其它情况为禁用（settings put secure clock_seconds $status 方案）
switch_cs=1

# cos13 系统设置延伸特性  例如：息屏指纹盲解
src_fccas=/my_product/etc/extension/feature_common_com.android.systemui.xml

# rui3~4 系统设置延伸特性  如：移动DC调光到开发者选项
src_rpref=`find /my_product/etc/extension/ -type f -iname realme_product_rom_extend_feature_$(getprop ro.separate.soft).xml 2>/dev/null`

# 屏幕刷新率重点应用名单
src_rrc=/my_product/etc/refresh_rate_config.xml

# 动态刷新率
# cos12~13
src_ovc=/my_product/etc/oplus_vrr_config.json
# cos11
[ -f $src_ovc ] || src_ovc=/my_product/etc/oplus_adfr_config.json

# 视频播放器帧率控制
# cos12~13
src_mdpl=/my_product/vendor/etc/multimedia_display_perf_list.xml
# cos11
[ -f $src_mdpl ] || src_mdpl=/my_product/vendor/etc/oppo_display_perf_list.xml

# 车联
src_fcl=/my_stock/etc/extension/feature_carlink.xml

# cos12~13 系统高温控制配置  去除ColorOS（realme 非GT模式）游戏锁帧率等限制（fps=0; 修改GPU、CPU为 -1 ; 严格(restrict) 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 后面的值都改成 0）
src_stcc=/odm/etc/temperature_profile/sys_thermal_control_config.xml

# rui3~4 去除 realme GT模式游戏锁帧率，修改同上“系统高温控制配置”
src_stcc_gt=/odm/etc/temperature_profile/sys_thermal_control_config_gt.xml

# 高温保护
src_shtp=`echo /odm/etc/temperature_profile/sys_high_temp_protect*.xml`

# cos12~13 高热配置
src_stc=/odm/etc/ThermalServiceConfig/sys_thermal_config.xml

# 加密温控
src_horae=/system_ext/etc/horae

# 温控节点温度阈值  off by default since v1.1.1 220921
# switch_thermal=TRUE

# 自带APN接入点配置  解除修改限制
src_apn=/system/product/etc/apns-conf.xml

# 内存拓展
list_hybridswap=$(ls -l /sys/block/zram0/hybridswap_* | grep ^'\-rw\-' | awk '{print $NF}')

# The config path of App cloner (应用分身)
src_smac=`find /system_ext/oppo/ /system_ext/oplus/ -type f -iname "sys_multi_app_config.xml" 2>/dev/null`

# 启动管理  删除黑名单应用（blacklist文件中 blacklistAPKNs变量）
src_blacklistMv=`$FTF "startup_manager.xml" 2>/dev/null`

# 启动V3配置列表  删除黑名单应用
# absent-in-rui2
src_blacklistMv3c=`$FTF "sys_startup_v3_config_list.xml" 2>/dev/null`

# 暗色模式第三方应用管理  内含强制启用深色模式的App包名
src_sdmtam=`find /data/oplus/os/darkmode/ /data/oppo/coloros/darkmode/ -type f -name "sys_dark_mode_third_app_managed.xml" 2>/dev/null`

# cos11~12 自启动白名单 系统推荐自启动的App包名列表 不在bootwhitelist.txt中的App占用不推荐自启的名额; Android 13 变为允许自启动而非推荐
if [ $API -lt 33 ]; then src_bootwhitelist=`$FTF "bootwhitelist.txt" 2>/dev/null`; fi;

# cos11 允许关联启动  无需自动编辑
# src_asw=`$FTF "associate_startup_whitelist.txt" 2>/dev/null`

# cos12~13 关联启动白名单  无需自动编辑
# src_acwl=`$FTF "associate_white_list.txt" 2>/dev/null`

# cos11~12 允许自启动应用名单  默认关闭对其自动修改，因频繁自启易发热且费电
# src12_bootallow=`$FTF "bootallow.txt" 2>/dev/null`

# cos13 推荐自启动
if [[ "$API" -eq "33" ]];then
src13_awl=`$FTF "autostart_white_list.txt" 2>/dev/null`
sleep 0;fi

# 最近任务管理可锁定数量
# cos12~13 欧加桌面 (Oplus launcher) 配置
src_bgApp=/data/user_de/0/com.android.launcher/shared_prefs/Configuration.xml
# cos11 OPPO Launcher
[ -f $src_bgApp ] || src_bgApp=/data/user_de/0/com.oppo.launcher/shared_prefs/Configuration.xml

# 安全支付的启用应用名单  禁用ROOT后打开支付软件时的报毒，需要禁用支付安全环境扫描，可以在系统设置里面手动关闭
src_spea=/data/data/com.coloros.securepay/files/enabledapp.xml

