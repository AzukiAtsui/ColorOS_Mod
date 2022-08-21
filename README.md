# ColorOS_Mod-README.md

# 作者信息

Shell script by 酷安@灼热的红豆;

e-mail address: [AzukiAtsui@163.com](mailto:AzukiAtsui@163.com) ;

# 脚本说明

须ROOT权限执行。修改内容详见下方更新日志。

推荐在升级系统后重跑此脚本 或 使用 [magisk模块](https://topjohnwu.github.io/Magisk/guides.html#magisk-modules) 在每次开机时自动执行此脚本（$MODPATH/service.sh)

| 函数 | 功能 |
| --- | --- |
| echoRgb | 转换echo颜色提高可读性 |
| abort | 红色echo并exit 1 |

| 变量 | 说明 |
| --- | --- |
| source_file | 源配置文件 |
| target_file | “热更新”文件，通常 target_file=/data/system/${source_file##*/} |
| source_file_edited | 复制源文件到可读写目录然后修改，默认为脚本目录 ./test 文件。如果需要 mount 挂载则自定义。 |
| ds | ds=/data/system 缩写减少字节😂 |
| bak_file | 备份可读写目录下的配置文件，默认"${source_file}.bak” |

# 修改机制说明

## “热更新”

```bash
mv -f $source_file $target_file
```

系统自动对比 /data/system/目录下同名文件 与底层分区内同名文件的时间，使用更新的文件参数。

## Linux 常用的修改只读目录下文件的方法

```bash
mount --bind $source_file_edited $source_file
```

对于dir挂载只生效同名文件。

取消挂载:

```bash
umount $target_file
```

# 更新日志

## **v1** by   AzukiAtsui   2022-08-21

1. 屏幕刷新率全局重点名单"3-1-2-3”
2. 动态刷新率(adfr)
3. 去除视频锁帧
4. 去除 ColorOS 高温控制器 部分限制。去除高温锁帧率; 修改GPU、CPU为 -1 ; 去除部分限制： 亮度 充电 调制解调器 禁用手电 停止录像 禁拍照 禁热点 禁Torch 禁插帧 刷新率 禁视频SR 禁超感画质引擎 disHBMHB 。
5. 去除 realme GT模式温控限制，同4. 
6. 修改温控 高温保护数值
7. 修改温控数值
8. 开机自启允许名单 部分尝试
9. 应用分身数量限制改为 999
10. 锁定后台数量限制改为 999

# 感谢

Anharmony@coolapk, realme UI 3.0 教程。

咸鱼C@coolapk & JasonLiao@coolapk, OnePlus 9 Pro ColorOS 12 教程。