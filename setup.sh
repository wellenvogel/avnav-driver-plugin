#! /bin/bash
usage(){
    echo "usage: $0 initial|enable module|disable module|remove module(all)|list|status [module]"
    exit -1
}
pdir="`dirname $0`"
. "$pdir/helper.sh"

modPar(){
    par="`modName \"$1\"`"
    mod="`modModule \"$1\"`"
    ver="`modVersion \"$1\"`"
    dir="/usr/src/$mod-$ver"
    dkmscfg="$dir/dkms.conf"
}

setAutoInstall(){
    local v=""
    if [ "$2" = YES ] ; then
        v=$2
    fi
    sed -i -e "s/AUTOINSTALL=.*/AUTOINSTALL=$v/" "$1" || err "unable to change $1" 
}

getStatus(){
    dkms status -m "$1" -v "$2" | sed 's/.* \([^ ]*\)$/\1/'
}

isBuild(){
    local s
    for s in built installed
    do
        if [ "$1" = "$s" ] ; then
            return 0
        fi
    done
    return 1
}

if [ "$1" = "initial" ] ; then
    echo "preparing all modules"
    allModules "$pdir" ADD | while read modstr
    do
        echo "adding $modstr"
        modPar "$modstr"
        if [ "$par" = "" -o "$mod" = "" -o "$ver" = "" ] ; then
            break
        fi
        [ ! -d "$dir" -o ! -f "$dkmscfg" ] && err "$dkmscfg not found"
        setAutoInstall "$dkmscfg" NO
        st="`getStatus $mod $ver`" 
        if [ "$st" = "" ] ; then
            dkms add -m $mod -v $ver || err "unable to add $par $mod $ver"
        fi
        if isBuild "$st" ; then
            echo "$modstr already build"
        else
            echo "building $modstr"    
            dkms build -m $mod -v $ver || err "unable to build $par $mod $ver"
        fi    
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
    modPar "$modstr"
    [ ! -d "$dir" -o ! -f "$dkmscfg" ] && err "$dkmscfg not found"
    rt=0
    if [ "$1" = enable ] ; then
        echo "enabling module $modstr"
        st="`getStatus $mod $ver`"
        if [ "$st" = "" ] ; then
            echo "adding module $modstr"
            dkms add -m $mod -v $ver || err "unable to run dkms add -m $mod -v $ver"
        fi
        if [ "$st" != "installed" ] ; then
            dkms install -m $mod -v $ver || err "unable to run dkms install -m $mod -v $ver"
            rt=1
        fi
        setAutoInstall "$dkmscfg" YES
    else
        echo "disabling module $modstr"
        st="`getStatus $mod $ver`"
        if [ "$st" = "installed" ] ; then
            dkms uninstall -m $mod -v $ver || err "unable to run dkms uninstall -m $mod -v $ver"
            rt=1
        fi
        setAutoInstall "$dkmscfg" NO
    fi
    echo "$1 $2 done..."
    exit $rt
fi

if [ "$1" = "remove" ] ; then
    if [ "$2" = "" ] ; then
        echo "missing parameter module"
        usage
    fi
    allModules "$pdir" | while read modstr
    do
        modPar "$modstr"
        if [ "$par" = "$2" -o "$2" = all ] ; then
            st="`getStatus $mod $ver`"
            if [ "$st" != "" ] ; then
                echo "removing $modstr"
                dkms remove -m $mod -v $ver
            fi
        fi
    done
    exit 0
fi
if [ "$1" = list ] ; then
    allModules "$pdir" | grep '^ADD=' | while read modstr
    do
        modPar "$modstr"
        echo "$par"
    done
    exit 0
fi

if [ "$1" = status ] ; then
    allModules "$pdir" | grep '^ADD=' | while read modstr
    do
        modPar "$modstr"
        st="`getStatus $mod $ver`"
        if [ "$st" = "" ] ; then
            st="disabled"
        fi
        if [ "$2" = "" -o "$2" = all -o "$2" = "$par" ] ; then
            echo "$par=$mod/$ver=$st"
        fi
    done
    exit 0
fi

if [ "$1" = obsolete ] ; then
    echo "removing obsolotes"
    allModules "$pdir" | grep '^OLD=' | while read modstr
    do
        modPar "$modstr"
        st="`getStatus $mod $ver`"
        if [ "$st" = "" ] ; then
            echo "nothing to do for $modstr"
        else
            echo "removing $modstr"
            dkms remove -m $mod -v $ver 
        fi
    done
    exit 0
fi

usage
