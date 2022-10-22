#!/bin/sh
workdir=$(cd $(dirname $0);pwd)
moddir=$workdir/magisk
rootpath=$(cd ~;pwd)

# Recursively clean
cleanall() {
  local T NM
  T=$1
  NM=$2
  {
    for o in `find $workdir -type $T -iname "$NM"`
    do
      rm -rf $o
    done
  }
}

fileclean() { cleanall f "$1" ; }
dirclean() { cleanall d "$1" ; }

fileclean "*.img"

dirclean "dts"
dirclean "sign"

[ -d $moddir/sign ] || mkdir -p $moddir/sign
touch $moddir/sign/'.placeholder'

