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
ver=v1.1.8
dayno=2
[ "$debug" -eq 1 ] && ver=debug
versioncode="${year: -2}$(date "+%m%d")$dayno"
tagname=$ver-$versioncode
zip_nm=ColorOS_Mod-$tagname.zip

# upd=1
new_json=$workdir/main.json
new_chg=$workdir/changelog.md
io_release=AzukiAtsui.github.io/ColorOS_Mod/release


mChg(){
# [All Changelogs](https://azukiatsui.github.io/ColorOS_Mod/release/changelog/)
echo "### $ver
#### Changelog
1. Fix \`unset switch_dtbo\` for preventing NOT-Snapdragon devices to modify dtbo, just in case boot-loop or BRICK.
2. Update avb.sh.
3. Lightweighting and improving functions in customize.sh.
4. **v1.1.8(2210182)** :
	* Clean temp file of dts.sh.
	* Correct STRING to \"STRING\" in [] to fix 'sh: STRING: unknown operand'.

#### 更新日志
1. 修复删除switch_dtbo变量，以阻止非高通设备修改dtbo，防止变砖。
2. 更新avb.sh。
3. 轻量化和改进安装脚本的函数。
4. **v1.1.8(2210182)** :
	* 清除dts.sh的临时文件。
	* 将[]中的 字符串 更正为 \"字符串\" 以修复“sh: 字符串: unknown operand”。
" >$new_chg
}

set_perm() {
	# chown $2:$3 $1 || return 1
	chmod $4 $1 || return 1
	# local CON=$5
	# [ -z $CON ] && CON=u:object_r:system_file:s0
	# chcon $CON $1 || return 1
}

set_perm_recursive() {
	find $1 -type d 2>/dev/null | while read dir; do
		set_perm $dir $2 $3 $4 $6
	done
	find $1 -type f -o -type l 2>/dev/null | while read file; do
		set_perm $file $2 $3 $5 $6
	done
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
	set_perm_recursive $workdir 0 0 755 644
	set_perm_recursive $workdir/magisk/bin 0 0 755 755
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
	\"zipUrl\": \"https://github.com/AzukiAtsui/ColorOS_Mod/releases/download/$tagname/$zip_nm\",
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
	git commit -m "ColorOS_Mod $ver($versioncode)"
	git push -u origin master
}

pvTag(){
	cd $workdir
	git add .
	git commit -m "$ver($versioncode)"
	git push -u origin main
	last_commit=$(git log --pretty=format:"%h" | head -1  | awk '{print $1}')
	git tag -d "$tagname"
	git push origin :refs/tags/$tagname
	git tag -a "$tagname" $last_commit -m ""
	git push origin "$tagname"
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

