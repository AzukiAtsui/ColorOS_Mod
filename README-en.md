# ColorOS_Mod

[中文版](https://github.com/AzukiAtsui/ColorOS_Mod/blob/main/README.md)

In the form of [Magisk Module](https://topjohnwu.github.io/magisk/guides.html#magisk-modules), extract and modify ColorOS or realmeUI system configs like thermal configs, bootallow application list, etc. during the module installation process. Systemless mount the modified file to achieve a more comfortable system experience. Disable or uninstall modules make system back to normal.

### INSTRUCTIONS

1. Download the latest version _ColorOS_Mod-MagiskModule.zip_ in [Releases](https://github.com/AzukiAtsui/ColorOS_Mod/releases);
2. Edit the _customize.sh_ in _ColorOS_Mod-latest.zip_ to turn off/on the functions in your own preference;
3. Start Magisk app, switch to the "Modules" page;
4. Click "Install from the storage" and select the _ColorOS_Mod.zip_ downloaded from [Releases](https://github.com/AzukiAtsui/ColorOS_Mod/releases);
5. Wait for Successful Installation then restart.

### Prebuilt binaries

- [mkdtimg](https://android.googlesource.com/platform/system/libufdt/+/refs/heads/master/utils/src/) , from AOSP
- [dtc](https://github.com/AzukiAtsui/dtc-aosp/tree/standalone)
- [bash](https://ftp.gnu.org/gnu/bash/) , from [GNU Project](https://www.gnu.org/software/bash/) . [bash-5.2-rc4 backup](https://pan.baidu.com/s/1bHtUdheyBgIwixLqpycgHg?pwd=bash) 提取码:bash

More info: [**ColorOS_Mod index**](https://azukiatsui.github.io/2022/09/22/ColorOS_Mod/)

# Changelog

## **v1.1.2** by   AzukiAtsui   2022-09-22

1. Update README, build.sh, dts.sh
2. Reduce bytes

## **MagiskModule_v1.1.1** by   AzukiAtsui   2022-09-21

1. Trying activating ColorOS swap (hybridswap)
2. Modify dtbo configs
3. Turn off the thermal node modification by default
4. BUGFIX

## **ScriptFile_v1.2** by   AzukiAtsui   2022-08-27

1. Adding app pkg name into 'Auto launch whitelist' / 'App cloner' / 'Dark mode for third-party apps'
2. Disable payment protection (environment security scanning)

## **ScriptFile_v1** by   AzukiAtsui   2022-08-21

_v1.1 fixed the error edited value of GPU in v1, automatically delete some space lines in configs._

1. Globally swap app refresh rate config to "3-1-2-3”
2. Move vvr config (adfr)
3. Unlock the media app refresh rate
4. 修改 ColorOS 高温控制器。去除高温锁帧率; 修改GPU、CPU为 -1 ; 去除部分限制：亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 。
5. 去除 realme GT模式温控限制，修改同4. 
6. 修改温控 高温保护数值
7. 修改温控数值
8. 开机自启允许名单 部分尝试
9. 应用分身数量限制改为 999
10. 锁定后台数量限制改为 999
