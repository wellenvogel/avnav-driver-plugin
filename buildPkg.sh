#! /bin/bash
#package build using https://github.com/goreleaser/nfpm on docker
pdir=`dirname $0`
pdir=`readlink -f "$pdir"`
. "$pdir/helper.sh"
#set -x
for sub in build src
do

  if [ -d "$pdir/$sub" ] ; then
    rm -rf "$pdir/$sub"
  fi  
  mkdir -p "$pdir/$sub" || err "unable to create $pdir/$sub"
done

for dir in RTL8188EU RTL8192EU
do
  dn="$pdir/$dir"
  [ ! -f "$dn/module" ] && err "$dn/module missing"
  echo "collecting $dir"
  mv=`cat "$dn/module"`
  echo "ADD=$dir=$mv" >> "$pdir/build/allmodules" 
  "$dn/prepare.sh" || err "unable to run $dn/prepare.sh"
done
cat "$pdir/oldmodules" >> "$pdir/build/allmodules"
config=package.yaml
version="$1"
if [ "$version" = "" ] ; then
  version=`date '+%Y%m%d'`
fi
echo building version $version
tmpf=package$$.yaml
rm -f $tmpf
sed "s/^ *version:.*/version: \"$version\"/" $config > $tmpf
config=$tmpf
docker run  --rm   -v "$pdir":/tmp/pkg   --user `id -u`:`id -g` -w /tmp/pkg goreleaser/nfpm:v2.28.0 pkg -p deb -f $config
rt=$?
if [ "$tmpf" != "" ] ; then
  rm -f $tmpf
fi
exit $rt
