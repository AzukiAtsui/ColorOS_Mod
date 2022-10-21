#!/bin/sh
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

# run example
# ver='v1.1.9' upd=0 dayno=1 . ~/ColorOS_Mod/build.sh

workdir=$(cd $(dirname $0);pwd)
moddir=$workdir/magisk
rootpath=$(cd ~;pwd)
year=$(date "+%Y")

source $moddir/script/.util

# 模块包属性
[ "$debug" -eq 1 ] && ver=debug
versioncode="${year: -2}$(date "+%m%d")$dayno"
tagname=$ver-$versioncode
zip_nm=ColorOS_Mod-$tagname.zip

# upd=1
new_json=$workdir/main.json
new_chg=$workdir/changelog.md
io_release=AzukiAtsui.github.io/ColorOS_Mod/release


rmTmp(){
. $workdir/clean.sh
}

mZip(){
if [ -d $workdir/magisk ];then
	pushd $workdir/magisk >/dev/null
	rmTmp
	set_perm_recursive $workdir 0 0 777 777
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
	\"changelog\": \"https://github.com/AzukiAtsui/ColorOS_Mod/raw/$branch/changelog.md\"
}" >$new_json
sed -i "1c ### _$ver$([ "$dayno" -gt 1 ] && echo "($dayno)")_  by   AzukiAtsui   $year-$(date "+%m-%d")" $new_chg
}

pJson(){
[[ $upd -eq 1 ]] || return 4
	if [ ! -d $rootpath/AzukiAtsui.github.io ];then
		cd $rootpath
		git clone git@github.com:AzukiAtsui/AzukiAtsui.github.io.git
	fi
	mv -f $new_json $rootpath/$io_release/main.json
	cd $rootpath/AzukiAtsui.github.io
	git add .
	git commit -m "ColorOS_Mod $ver($versioncode)"
	git push -u origin main
}

pvTag(){
	cd $workdir
	git add .
	git commit -m "Release $branch edition $ver($versioncode)"
	git push -u origin $branch
	last_commit=$(git log --pretty=format:"%h" | head -1  | awk '{print $1}')
		# delete old same-name tag
		git tag -d "$tagname"
		git push origin :refs/tags/$tagname
	git tag -a "$tagname" $last_commit -m ""
	git push origin "$tagname"
}

main(){
[ -z $ver ] && return 77
if [ -z $dayno ];then return 76
else [ -z $branch ] && return 75 ;fi
	mZip
	mJson
	pJson
	if [ $? -eq 4 ];then return 66;fi
	pvTag
}

main
case $? in
	77) echo "请定义版本号变量，如：ver='v1.1.9'";;
	76) echo "请定义次数变量，如：dayno=1";;
	75) echo "请定义需要上传的远端分支名，如：branch=dev";;
	66) echo "变量upd≠1，故不上传远端";;
	*) echo "完成";;
esac

