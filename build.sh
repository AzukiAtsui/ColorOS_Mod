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
ver=v1.1.0
versioncode=2209181
zip_nm=ColorOS_Mod-$ver-$versioncode-MagiskModule.zip
version=$ver\($versioncode\)

upd=false
new_json=$workdir/main.json
new_chg=$workdir/changelog.md
io_release=AzukiAtsui.github.io/ColorOS_Mod/release


mChg(){
# Template of "changelog": "https://azukiatsui.github.io/ColorOS_Mod/release/changelog.md"
echo "## $version

### Changelog
1. Trying activating ColorOS swap (hybridswap)
2. Modify dtbo configs
3. Turn off the thermal node modification by default
4. Raise the probability of using 5G signal after falling 4G
5. bugfix

### 更新日志
1. 尝试激活内存拓展（hybridswap）
2. 修改 dtbo 配置
3. 默认关闭温控节点修改
4. 提高掉落4G后回升5G概率
5. 修复已知问题
" >$new_chg

}

mZip(){
if [ -d $workdir/magisk ];then
	pushd $workdir/magisk >/dev/null
	chmod 777 $(find .)
		sed -i 's/version=.*/version='$version'/g' module.prop
		sed -i 's/versioncode=.*/versioncode='$versioncode'/g' module.prop
		zip -9 -r $zip_nm * 2>/dev/null >/dev/null
		mv -f $zip_nm $workdir
	popd >/dev/null
fi
}

mJson(){
# Template of updateJson=https://azukiatsui.github.io/ColorOS_Mod/release/main.json
echo "{
	\"version\": \"$version\",
	\"versionCode\": $versioncode,
	\"zipUrl\": \"https://github.com/AzukiAtsui/ColorOS_Mod/releases/download/$versioncode/$zip_nm\",
	\"changelog\": \"https://azukiatsui.github.io/ColorOS_Mod/release/changelog.md\"
}" >$new_json

}

pJson(){
[[ $upd == false ]] && return 4
		cd $rootpath/AzukiAtsui.github.io
		git checkout main
		git add .
		git commit -m "ColorOS_Mod $version"
		git push -u origin main
}

pvTag(){
	# cd $workdir
	# git add .
	# git commit -m "$version"
	# last_commit=$(git log | awk 2)
	# git tag -a "$versioncode" $last_commit -m "$version"
	# git push origin $versioncode
	return
}

main(){
	mJson
	mChg
	mZip
	if [ -f $rootpath/$io_release/main.json ];then
		mv -f $new_json $rootpath/$io_release/main.json
		mv -f $new_chg $rootpath/$io_release/changelog.md
		pJson
	else
		cd $rootpath
		git clone -b main git@github.com:AzukiAtsui/AzukiAtsui.github.io.git
		# git checkout -b main origin/main
		mv -f $new_json $rootpath/$io_release/main.json
		mv -f $new_chg $rootpath/$io_release/changelog.md
		pJson
		[ $? -eq 4 ] && echo "变量upd=false，故不上传"
		return
	fi
	pvTag
}

main

