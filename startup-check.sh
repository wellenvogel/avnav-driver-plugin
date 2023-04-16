#! /bin/bash
err(){
    echo "ERROR: $*"
    exit 1
}

usage(){
    echo "usage: $0 initial|enable module|disable module"
    exit 1
}
pdir="`dirname $0`"
if [ "$1" = "initial" ] ; then
    echo "preparing all modules"
    [ ! -f "$pdir/allmodules" ] && err "$pdir/allmodules not found"
    tr '=/' '  ' <  "$pdir/allmodules" | while read par mod ver
    do
        if [ "$par" = "" -o "$mod" = "" -o "$ver" = "" ] ; then
            break
        fi
        dkms add -m $mod -v $ver || err "unable to add $par $mod $ver"
        dkms build -m $mod -v $ver || err "unable to build $par $mod $ver"
        dkms remove -m $mod -v $ver || err "unable to remove $par $mod $ver"
    done
    echo "done..."
    exit 0
fi
if [ "$1" = "enable" -o "$1" = "disable" ] ; then
    if [ "$2" = "" ] ; then
        echo "missing module"
        usage
    fi
    modver="`grep \"$2=\" \"$pdir/allmodules\"`"
    [ "$modver" = "" ] && err "$2 not found in modules"
    dirname="/usr/src/"`echo \"$modver\" | tr / -`
    dkmscfg="$dirname/dkms.conf"
    [ ! -d "$dirname" -o ! -f "$dkmscfg" ] || err "$dkmscfg not found"
    mod=`echo "$modver" | awk 'BEGIN {FS="/"};{print $1;}'`
    ver=`echo "$modver" | awk 'BEGIN {FS="/"};{print $2;}'`
    if [ "$1" = enable ] ; then
        echo "enabling module $modver"
        dkms install -m $mod -v $ver || err "unable to run dkms install -m $mod -v $ver"
        sed -i -e 's/AUTOINSTALL=.*/AUTOINSTALL="YES"/' "$dkmscfg" || err "unable to change $dkmscfg"
    else
        echo "disabling module $modver"
        dkms uninstall -m $mod -v $ver || err "unable to run dkms uninstall -m $mod -v $ver"
        sed -i -e 's/AUTOINSTALL=.*/AUTOINSTALL="NO"/' "$dkmscfg" || err "unable to change $dkmscfg"
    fi
    echo "$1 $2 done..."
    exit 0
fi

usage