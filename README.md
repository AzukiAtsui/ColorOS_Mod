# ColorOS_Mod

[English version](https://github.com/AzukiAtsui/ColorOS_Mod/blob/main/README-en.md)

[**更新日志**](https://azukiatsui.github.io/ColorOS_Mod/release/changelog/)

了解更多：[**ColorOS_Mod 主页**](https://azukiatsui.github.io/2022/09/22/ColorOS_Mod/)

以 [Magisk模块](https://topjohnwu.github.io/Magisk/guides.html#magisk-modules) 的形式，在模块安装过程中提取 ColorOS 或 realmeUI 底层温控、自启/应用分身名单等并加以**修改**，systemless 挂载修改后的文件来实现更舒服的系统体验。禁用或卸载模块即可复原。

### 使用说明

1. 在 [Releases](https://github.com/AzukiAtsui/ColorOS_Mod/releases) 下载最新版 _ColorOS_Mod-MagiskModule.zip_ ；
2. 编辑 _ColorOS-latest.zip_ 内的 _customize.sh_ ，按自己喜好启用或关闭功能；
3. 打开 Magisk 管理器，切到“模块”页；
4. 点“从本地安装”，选中在 [Releases](https://github.com/AzukiAtsui/ColorOS_Mod/releases) 下载的 _ColorOS_Mod-MagiskModule.zip_ ；
5. 等待安装完成，然后重启。

### 预编译的二进制文件

- [mkdtimg](https://android.googlesource.com/platform/system/libufdt/+/refs/heads/master/utils/src/) ，来自 AOSP
- [dtc](https://github.com/AzukiAtsui/dtc-aosp/tree/standalone)
- [bash](https://ftp.gnu.org/gnu/bash/) ，来自 [GNU Project](https://www.gnu.org/software/bash/) 。[bash-5.2-rc4 备份](https://pan.baidu.com/s/1bHtUdheyBgIwixLqpycgHg?pwd=bash) 提取码:bash

