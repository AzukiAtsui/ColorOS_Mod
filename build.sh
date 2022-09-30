#
# This file is part of ColorOS_Mod.
# Copyright (C) 2022  AzukiAtsui
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

workdir=$(cd $(dirname $0);pwd)
rootpath=$(cd ~;pwd)

# 模块包属性
ver=v1.1.4
versioncode=2209301
zip_nm=ColorOS_Mod-$ver-$versioncode.zip

upd=1
new_json=$workdir/main.json
new_chg=$workdir/changelog.md
io_release=AzukiAtsui.github.io/ColorOS_Mod/release


mChg(){
# [All Changelogs](https://azukiatsui.github.io/ColorOS_Mod/release/changelog/)
echo "## $ver
### Changelog
1. Add avb.sh
2. Update getting info of device
3. Revert service.sh system.prop to v1.1.2

### 更新日志
1. 新增改 vbmeta分区 16进制数据 123位flag 关AVB的方法（感谢 @情非得已c）
2. 更新获取设备信息
3. 回退 service.sh system.prop 两个文件到 v1.1.2 版本


## v1.1.3
### Changelog
1. Fix ERROR of recovery dtbo while uninstall
2. Optimize existing features

### 更新日志
1. 修复：卸载模块时，恢复dtbo出错
2. 优化已有功能
" >$new_chg
}

mZip(){
if [ -d $workdir/magisk ];then
	pushd $workdir/magisk >/dev/null
	chmod 777 $(find .)
		sed -i 's/version=.*/version='$ver'/g' module.prop
		sed -i 's/versioncode=.*/versioncode='$versioncode'/g' module.prop
		7z a -r $zip_nm * 2>/dev/null >/dev/null
		mv -f $zip_nm $workdir/..
	popd >/dev/null
fi
}

mJson(){
# Template of updateJson=https://azukiatsui.github.io/ColorOS_Mod/release/main.json
echo "{
	\"version\": \"$ver\",
	\"versionCode\": $versioncode,
	\"zipUrl\": \"https://github.com/AzukiAtsui/ColorOS_Mod/releases/download/$versioncode/$zip_nm\",
	\"changelog\": \"https://github.com/AzukiAtsui/ColorOS_Mod/raw/main/changelog.md\"
}" >$new_json
}

pJson(){
[[ $upd -eq 1 ]] || return 4
	if [ ! -d $rootpath/AzukiAtsui.github.io ];then
		cd $rootpath
		git clone -b master git@github.com:AzukiAtsui/AzukiAtsui.github.io.git
	fi
	mv -f $new_json $rootpath/$io_release/main.json
	cd $rootpath/AzukiAtsui.github.io
	git add .
	git commit -m "ColorOS_Mod $ver"
	git push -u origin master
}

pvTag(){
	cd $workdir
	git add .
	git commit -m "$ver"
	git push -u origin main
	last_commit=$(git log --pretty=format:"%h" | head -1  | awk '{print $1}')
	git tag -d "$versioncode"
	git push origin :refs/tags/$versioncode
	git tag -a "$versioncode" $last_commit -m "$ver"
	git push origin $versioncode
}

main(){
	mJson
	mChg
	mZip
	pJson
	if [ $? -eq 4 ];then
		echo "变量upd≠1，故不上传"
	fi
	pvTag
}

main

