### v1.1.8
#### Changelog
1. Fix `unset switch_dtbo` for preventing NOT-Snapdragon devices to modify dtbo, just in case boot-loop or BRICK.
2. Update avb.sh.
3. Lightweighting and improving functions in customize.sh.
4. **v1.1.8(2210182)** :
	* Clean temp file of dts.sh.
	* Correct STRING to "STRING" in [] to fix 'sh: STRING: unknown operand'.

#### 更新日志
1. 修复删除switch_dtbo变量，以阻止非高通设备修改dtbo，防止变砖。
2. 更新avb.sh。
3. 轻量化和改进安装脚本的函数。
4. **v1.1.8(2210182)** :
	* 清除dts.sh的临时文件。
	* 将[]中的 字符串 更正为 "字符串" 以修复“sh: 字符串: unknown operand”。

