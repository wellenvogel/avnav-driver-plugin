#! /bin/bash
DLNAME=RTL8188EU.zip
pdir="`dirname $0`"
pdir="`readlink -f \"$pdir\"`"
BUILD="$pdir/../build"
SRC="$pdir/../src"
TNAME=`cat "$PDIR/module" | tr / -`
rm -f "$BUILD/$DLNAME"
( cd $BUILD && curl -o $DLNAME https://github.com/lwfinger/rtl8188eu/archive/refs/heads/v5.2.2.4.zip ) || exit 1
( cd $SRC &&  unzip "$BUILD/$DLNAME")
for f in patch/*
do
    bn=`basename $f`
    cp $f "$SRC/$bn" || exit 1
    sed -i -e "s/#MODULE#/$TNAME" "$SRC/$bn"
done      
