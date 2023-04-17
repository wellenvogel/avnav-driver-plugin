#! /bin/bash
usage(){
    echo "usage: $0 initial|enable module|disable module"
    exit 1
}
pdir="`dirname $0`"
. "$pdir/helper.sh"
if [ "$1" = "initial" ] ; then
    echo "preparing all modules"
    allModules "$pdir" ADD | while read modstr
    do
        echo "adding $modstr"
        par="`modName \"$modstr\"`"
        mod="`modModule \"$modstr\"`"
        ver="`modVersion \"$modstr\"`"
        if [ "$par" = "" -o "$mod" = "" -o "$ver" = "" ] ; then
            break
        fi
        dirname="/usr/src/$mod-$ver"
        dkmscfg="$dirname/dkms.conf"
        [ ! -d "$dirname" -o ! -f "$dkmscfg" ] && err "$dkmscfg not found"
        sed -i -e 's/AUTOINSTALL=.*/AUTOINSTALL="NO"/' "$dkmscfg" || err "unable to change $dkmscfg"
        dkms add -m $mod -v $ver || err "unable to add $par $mod $ver"
        dkms build -m $mod -v $ver || err "unable to build $par $mod $ver"
    done
    echo "done..."
    exit 0
fi
if [ "$1" = "enable" -o "$1" = "disable" ] ; then
    if [ "$2" = "" ] ; then
        echo "missing module"
        usage
    fi
    modstr="`findModule \"$pdir\" \"$2\"`"
    [ "$modstr" = "" ] && err "$2 not found in modules"
    mod="`modModule \"$modstr\"`"
    ver="`modVersion \"$modstr\"`"
    dirname="/usr/src/$mod-$ver"
    dkmscfg="$dirname/dkms.conf"
    [ ! -d "$dirname" -o ! -f "$dkmscfg" ] && err "$dkmscfg not found"
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
