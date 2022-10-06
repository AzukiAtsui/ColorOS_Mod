#
# This file is part of ColorOS_Mod.
# Copyright 2022 AzukiAtsui
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
year=$(date "+%Y")

# 模块包属性
ver=v1.1.6
dayno=2
[ "$debug" -eq 1 ] && ver=debug
versioncode="${year: -2}$(date "+%m%d")$dayno"
zip_nm=ColorOS_Mod-$ver-$versioncode.zip

upd=1
new_json=$workdir/main.json
new_chg=$workdir/changelog.md
io_release=AzukiAtsui.github.io/ColorOS_Mod/release


mChg(){
# [All Changelogs](https://azukiatsui.github.io/ColorOS_Mod/release/changelog/)
echo "### $ver
#### Changelog
1. Continue the work of v1.1.5 changelog point 2 ~ 4.

#### 更新日志
1. 继续v1.1.5更新日志中第2~4点的工作。

### v1.1.5
#### Changelog
1. Update binaries compiled using NDK_r24 aarch64-linux-android31-clang. Thank [affggh](https://github.com/affggh/) and [望月古川](http://www.coolapk.com/u/843974).
2. Optimize process.
3. New dynamically update \"App cloner\" allowed list, Auto/Assosiated lanch recommend list.
4. Detach blacklist, whitelist and switches.sh from customize.sh for better modifing them and better repeatedly sourcing them. 

#### 更新日志
1. 更新使用 NDK_r24 aarch64-linux-android31-clang 编译的二进制。感谢 [affggh](https://github.com/affggh/) 和 [望月古川](http://www.coolapk.com/u/843974)。
2. 优化流程。
3. 新增动态更新应用分身允许名单、推荐自启/关联启动名单。
4. 从 customize.sh(安装脚本) 分离出 blacklist(黑名单)、whitelist(白名单) 和 switches.sh(开关控制) 以便修改它们和更容易地重复引用它们。
" >$new_chg
}

rmTmp(){
rm -rf `find $workdir -type f -iname "*.zip"` `find $workdir -type f -iname '*.img'` dts sign
[ -d ./sign ] || mkdir -p ./sign
touch ./sign/'.placeholder'
}

mZip(){
if [ -d $workdir/magisk ];then
	pushd $workdir/magisk >/dev/null
	rmTmp
	chmod -R 777 *
		sed -i 's/version=.*/version='$ver'/g' module.prop
		sed -i 's/versioncode=.*/versioncode='$versioncode'/g' module.prop
		7z a -r $zip_nm * >/dev/null
		mv -f $zip_nm $workdir
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
	mZip
	mJson
	mChg
	pJson
	if [ $? -eq 4 ];then return 66;fi
	pvTag
}

main
case $? in
	66) echo "变量upd≠1，故不上传";;
	*) echo "完成";;
esac

