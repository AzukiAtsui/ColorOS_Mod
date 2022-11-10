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

MODDIR=${0%/*}
MODBIN=$MODDIR/bin
MODCONFIG=$MODDIR/config
MODSCRIPT=$MODDIR/script
MODSIGN=$MODDIR/sign

while [ "$(getprop sys.boot_completed)" != "1" ]; do
	sleep 1;
done

# Make SafetyNet pass
resetprop ro.boot.flash.locked 1
# Revert changes when boot completed
resetprop ro.boot.vbmeta.device_state locked
resetprop ro.boot.verifiedbootstate green

[ "`cat $MODSIGN/service.sh`" == "1" ] || exit 0

# Add new-installed third party app package name to lists.
## `pm` should run in booted Android system
APKNs=$(pm list packages -3 | sed 's/.*://')

## remove $blacklisAPKNs from lists.
source $MODCONFIG/blacklist

## function for simple lists.
anapkn() {
	if [[ -f $1 ]]; then
		sed -i -e "/$APKN\$/d" -e '$a'"$APKN" $1;
	fi;
}
bdapkn() {
	if [[ -f $1 ]]; then
		sed -i -e "/$APKN\$/d" $1;
	fi;
}
### mod
for APKN in $APKNs; do
	multiAPKN="<item name=\"$APKN\" \/>";
	[ -f $appClonerList ] && sed -i -e "/$multiAPKN/d" -e '/<allowed>/a'"$multiAPKN" $appClonerList;
	darkAPKN="<p attr=\"$APKN\"\/>";
	[ -f $darkList ] && sed -i -e "/$APKN/d" -e '/<\/filter-conf>/i'"$darkAPKN" $darkList;
	anapkn $bootWhiteList;
	anapkn $autostartWhiteList;
	anapkn $darkOList;
	anapkn $darkCList;
done

for APKN in $blacklistAPKNs; do
	bdapkn $bootWhiteList;
	bdapkn $autostartWhiteList;
done

for APKN in $(cat $MODCONFIG/blacklist_dark); do
	bdapkn $darkOList;
done

# disable service.sh
echo 2 >$MODSIGN/service.sh

pstree $$ -p | awk -F "[()]" '{print $2}' | xargs kill -9

