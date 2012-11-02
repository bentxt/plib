#!/bin/sh

curdir=$(pwd)
here=$(basename $curdir)

[ x`readlink plib` = 'x' ] || {
    cd plib
    p=$(pwd -P)
    cd $curdir
    rm -rf plib
    cp -r $p plib
    rm -rf plib/.git
}

hd=$( cat Version.txt | awk -F: '{ print $1 }')
txt=$( cat Version.txt | awk -F: '{ print $2 }')

pkg=$( echo $hd | awk '{ print $1 }')
vers=$( echo $hd | awk '{ print $2 }')
date=$( echo $hd | awk '{ print $3 }')
date=$( echo $date | sed 's/(//g' )
date=$( echo $date | sed 's/)//g' )

nm=${pkg}-${vers}_${date}
fnm=${nm}.tar.gz

cd ..

[ -f "rel/${fnm}" ] && { echo "ERR: release with $fnm alreade here, exit"; exit 1; }

cp -r $pkg $nm
rm -rf ${nm}/.git
[ -e 'rel' ] || mkdir rel

tar cfvz $fnm $nm
pandoc -f markdown -t html $nm/Readme.txt > rel/${nm}.html
mv $fnm rel/
rm -rf $nm


