#!/bin/sh
workdir=$(cd $(dirname $0);pwd)
moddir=$workdir/magisk
rootpath=$(cd ~;pwd)

source $moddir/script/.util

fileclean "*.zip"
fileclean "*.img"

dirclean "dts"
dirclean "sign"

[ -d $moddir/sign ] || mkdir -p $moddir/sign
touch $moddir/sign/'.placeholder'

