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
  sleep 1
done

# Make SafetyNet pass
resetprop ro.boot.flash.locked 1
# Revert changes when boot completed
resetprop ro.boot.vbmeta.device_state locked
resetprop ro.boot.verifiedbootstate green

