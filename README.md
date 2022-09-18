# ColorOS_Mod

[English version](https://github.com/AzukiAtsui/ColorOS_Mod/README-en.md)

以 [Magisk模块](https://topjohnwu.github.io/Magisk/guides.html#magisk-modules) 的形式，在模块安装过程中提取 ColorOS 或 realmeUI 底层温控、自启/应用分身名单等并加以**修改**，systemless 挂载修改后的文件来实现更舒服的系统体验。禁用或卸载模块即禁用修改。

### 使用说明

1. 在 [Releases](https://github.com/AzukiAtsui/ColorOS_Mod/releases) 下载 _ColorOS_Mod-MagiskModule.zip_ ；
2. 打开 Magisk 管理器，切到“模块”页；
3. 点“从本地安装”，选中在 [Releases](https://github.com/AzukiAtsui/ColorOS_Mod/releases) 下载的 _ColorOS_Mod-MagiskModule.zip_ ；
4. 等待安装完成，然后重启。

### 预编译的二进制文件

- [mkdtimg](https://android.googlesource.com/platform/system/libufdt/+/refs/heads/master/utils/src/) ，来自 AOSP
- [dtc](https://github.com/AzukiAtsui/dtc-aosp/tree/standalone)
- [bash](https://ftp.gnu.org/gnu/bash/) ，来自 [GNU Project](https://www.gnu.org/software/bash/) 。[bash-5.2-rc4 备份](https://pan.baidu.com/s/1bHtUdheyBgIwixLqpycgHg?pwd=bash) 提取码:bash

了解更多：[ColorOS_Mod 主页](https://azukiatsui.github.io/ColorOS_Mod/index.md)

# 更新日志

## **MagiskModule_v1.1.0** by   AzukiAtsui   2022-09-18

1. 尝试激活内存拓展（hybridswap）
2. 修改 dtbo 配置
3. 默认关闭温控节点修改
4. 提高掉落4G后回升5G概率
5. 修复已知问题

## **ScriptFile_v1.2** by   AzukiAtsui   2022-08-27

1. 分别添加所有第三方APP包名到自启白名单、开机自启允许名单、应用分身名单、三方应用暗色名单
2. 禁用支付安全环境扫描

## **ScriptFile_v1** by   AzukiAtsui   2022-08-21

_v1.1 修复v1 中gpu值修改出错，增加删除空行_

1. 屏幕刷新率全局重点名单"3-1-2-3”
2. 动态刷新率(adfr)
3. 去除视频锁帧
4. 修改 ColorOS 高温控制器。去除高温锁帧率; 修改GPU、CPU为 -1 ; 去除部分限制：亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 。
5. 去除 realme GT模式温控限制，修改同4. 
6. 修改温控 高温保护数值
7. 修改温控数值
8. 开机自启允许名单 部分尝试
9. 应用分身数量限制改为 999
10. 锁定后台数量限制改为 999
