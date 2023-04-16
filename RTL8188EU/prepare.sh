#! /bin/bash
err(){
    echo "ERROR: $*"
    exit 1
}
DLNAME=RTL8188EU.zip
pdir="`dirname $0`"
pdir="`readlink -f \"$pdir\"`"
BUILD="$pdir/../build"
SRC="$pdir/../src"
MODULE=`awk 'BEGIN {FS="/"};{print $1;}' < "$pdir/module"`
VERSION=`awk 'BEGIN {FS="/"};{print $2;}' < "$pdir/module"`
TNAME="$MODULE-$VERSION"
rm -f "$BUILD/$DLNAME"
rm -rf "$SRC/$TNAME"
( cd $BUILD && curl -L  -o $DLNAME "https://github.com/lwfinger/rtl8188eu/archive/refs/heads/v5.2.2.4.zip" ) || exit 1
( cd $SRC &&  unzip "$BUILD/$DLNAME")
[ ! -d "$SRC/$TNAME" ] && err "$SRC/$TNAME not found after unpack"
for f in $pdir/patch/*
do
    bn=`basename $f`
    cp $f "$SRC/$TNAME/$bn" || exit 1
    sed -i -e "s/#MODULE#/$MODULE/" -e "s/#VERSION#/$VERSION/" "$SRC/$TNAME/$bn"
done      
