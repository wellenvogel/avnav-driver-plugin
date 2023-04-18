#! /bin/bash
DLNAME=RTL8192EU.zip
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
curl -L  -o "$BUILD/$DLNAME" "https://github.com/Mange/rtl8192eu-linux-driver/archive/refs/heads/realtek-4.4.x.zip" || exit 1
( cd $SRC &&  unzip "$BUILD/$DLNAME" && mv "rtl8192eu-linux-driver-realtek-4.4.x" "$TNAME")
[ ! -d "$SRC/$TNAME" ] && err "$SRC/$TNAME not found after unpack"
copyPatches "$pdir"
( cd "$SRC/$TNAME" && patch -p0 -f ) < "$pdir/patchMake"
