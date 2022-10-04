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

while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1
done

# Make SafetyNet pass
resetprop ro.boot.flash.locked 1
# resetprop ro.boot.vbmeta.device_state locked
resetprop ro.boot.verifiedbootstate green

APKNs=$(pm list packages -3 | sed 's/.*://')
source $MODDIR/blacklist

for APKN in $APKNs;do multiAPKN="<item\ name\=\"$APKN\"\ \/>"
	if [[ -z "$(grep "$multiAPKN" $appClonerList)" ]];then
		# Add new-installed third party app package name to the list.
		sed -i '/<allowed>/a'"$multiAPKN" $appClonerList;fi
	if [[ -z "$(grep "$APKN" $bootallow13List)" ]];then sed -i -e '/'$APKN'$/d' -e '$a'"$APKN" $bootallow13List;fi
	if [[ -z "$(grep "$APKN" $associatedList)" ]];then sed -i -e '/'$APKN'$/d' -e '$a'"$APKN" $associatedList;fi;done

