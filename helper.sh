#! /bin/bash
err(){
    echo "ERROR: $*" >&2
    exit 1
}

#$1: module ADD=NAME=mod/version
splitModule(){
    echo "$1" | tr '=/' '  '
}
#$1: module ADD=NAME=mod/version
modName(){
    local v
    IFS="=/" read -ra v <<< "$1"
    echo "${v[1]}"
}
#$1: module ADD=NAME=mod/version
modModule(){
    local v
    IFS="=/" read -ra v <<< "$1"
    echo "${v[2]}"
}
#$1: module ADD=NAME=mod/version
modVersion(){
    local v
    IFS="=/" read -ra v <<< "$1"
    echo "${v[3]}"
}
#$1: module ADD=NAME=mod/version
modMode(){
    local v
    IFS="=/" read -ra v <<< "$1"
    echo "${v[0]}"
}
#$1: dir for allmodules
#$2: if set - filter
allModules(){
    local fn="$1/allmodules"
    [ ! -f "$fn" ] && err "modules file $fn not found"
    if [ "$2" = "" ] ; then
        cat $fn
    else
        grep "$2=" $fn
    fi
}
#$1: dir for allmodules
#$2: module name
findModule(){
    allModules "$1" | grep "ADD=$2="
}
#$1: module dir
getLocalModule(){
    local mname="$1/module"
    [ ! -f "$mname" ] && err "unable to find $mname"
    echo "ADD=`basename \"$1\"`=`cat \"$mname\"`"
}
#$1: module dir
copyPatches(){
    local patchdir="$1/patch"
    [ ! -d "$patchdir" ] && return 0
    local modstr="`getLocalModule \"$1\"`"
    [ "$modstr" = "" ] && err "no local module for $1"
    mod=`modModule "$modstr"`
    ver=`modVersion "$modstr"`
    local src="$1/../src/$mod-$ver"
    [ ! -d "$src" ] && err "no source dir $src for $1"
    local f
    local bn
    for f in "$patchdir"/*
    do
        bn=`basename $f`
        cp $f "$src/$bn" || err "unable to copy $f to $src/$bn"
        sed -i -e "s/#MODULE#/$mod/" -e "s/#VERSION#/$ver/" "$src/$bn" || err "unable to adapt patch $src/$bn"
    done
}
