#dotd!/bin/sh

id="$0"

curdir=$(dirname $id)

idres=$(readlink $id)
[ -n "$idres" ] && curdir="$(dirname $idres)"


rt=

if [ $# -gt 1 ] ; then
    rt="$1"
    fi
if [ "$rt" = 'perl' ] ;then
    shift
    perl -Mlib='.' -MPlib "$@"
elif [ "$rt" = 'sleep' ]; then
    shift
    java -jar "$curdir"/misc/sleep.jar "$@"
else
    fl=$(basename $1)
    ext=${fl##*.}

    if [ "$ext" = 'pl' ]; then
        perl -Mlib='.' -MPlib "$@"
    elif [ "$ext" = 'sl' ]; then
        java -jar "$curdir"/misc/sleep.jar "$@"
    else
        echo "File $@ and ext $ext is unknown"
        exit 1
   fi
fi
