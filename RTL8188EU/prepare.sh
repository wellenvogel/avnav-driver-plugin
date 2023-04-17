#! /bin/bash
DLNAME=RTL8188EU.zip
pdir="`dirname $0`"
pdir="`readlink -f \"$pdir\"`"
. "$pdir/../helper.sh"
BUILD="$pdir/../build"
SRC="$pdir/../src"
modstr="`getLocalModule \"$pdir\"`"
MODULE=`modModule "$modstr"`
VERSION=`modVersion "$modstr"`
TNAME="$MODULE-$VERSION"
rm -f "$BUILD/$DLNAME"
rm -rf "$SRC/$TNAME"
curl -L  -o "$BUILD/$DLNAME" "https://github.com/lwfinger/rtl8188eu/archive/refs/heads/v5.2.2.4.zip" || exit 1
( cd $SRC &&  unzip "$BUILD/$DLNAME")
[ ! -d "$SRC/$TNAME" ] && err "$SRC/$TNAME not found after unpack"
copyPatches "$pdir"
