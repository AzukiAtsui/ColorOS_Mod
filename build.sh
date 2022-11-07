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
# upd=0 ver='v1.4.0' . ~/ColorOS_Mod/build.sh

workdir=$(cd $(dirname $0);pwd)
moddir=$workdir/magisk
rootpath=$(cd ~;pwd)
year=$(date "+%Y")

# 模块包属性
[ "$debug" -eq 1 ] && ver=debug
dayno=${dayno:-1}
versioncode="${year: -2}$(date "+%m%d")$dayno"
tagname=$ver-$versioncode
zip_nm=ColorOS_Mod-$tagname.zip

# upd=1
branch=${branch:-`git branch |sed -n '/\*/s/* //p'`}
new_json=$workdir/${branch}.json
new_chg=$workdir/changelog.md
io_release=AzukiAtsui.github.io/ColorOS_Mod/release

source "$moddir/script/.util"

rmTmp(){
	. "$workdir/clean.sh"
}

mZip(){
	if [ -d "$workdir/magisk" ];then
		pushd "$workdir/magisk" >/dev/null
		rmTmp
		set_perm_recursive $workdir 0 0 777 777
		echo "id=coloros_mod
name=ColorOS_Mod
version=$ver
versioncode=$versioncode
author=AzukiAtsui
description=Modify ColorOS and realmeUI configs. Repo: https://github.com/AzukiAtsui/ColorOS_Mod
updateJson=https://$io_release/${branch}.json" >module.prop
		7z a -r $zip_nm * >/dev/null
		mv -f $zip_nm "$workdir"
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
}" >"$new_json"
	sed -i "1c ### _$ver$([ "$dayno" -gt 1 ] && echo "($dayno)")_  by   AzukiAtsui   $year-$(date "+%m-%d")" "$new_chg"
}

pJson(){
	if [ ! -d "$rootpath/AzukiAtsui.github.io" ];then
		cd "$rootpath"
		git clone git@github.com:AzukiAtsui/AzukiAtsui.github.io.git
	fi
	mv -f "$new_json" "$rootpath/$io_release/${branch}.json"
	cd "$rootpath/AzukiAtsui.github.io"
	git add .
	git commit -m "ColorOS_Mod $branch $ver($versioncode)"
	git push -u origin main
}

pvTag(){
	cd "$workdir"
	git add .
	git commit -m "Release $branch edition $ver($versioncode)"
	# require a pull request before merging due to main branch protection rule.
	git push -u origin dev
	last_commit=$(git log --pretty=format:"%h" | head -1  | awk '{print $1}')
		# delete old same-name tag
		git tag -d "$tagname"
		git push origin :refs/tags/$tagname
	git tag -a "$tagname" $last_commit -m "$branch"
	git push origin "$tagname"
}

main(){
	[ -z "$ver" ] && return 77
	mZip
	mJson
	[ $upd -ne 1 ] && return 66
	pJson
	pvTag
}

main
case $? in
	77) echo "请定义版本号变量，如：ver='v1.1.9'";;
	66) echo "变量upd≠1，故不上传远端";;
	*) echo "完成";;
esac

