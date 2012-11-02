#!/bin/bash

p=suite
declare -a tests=(include1 echo1);

die (){ echo "$@"; exit 1; }

for t in "${tests[@]}"; do
  plfile=${t}.pl
  slfile=${t}.sl
  [ -f $p/$plfile ] || die "ERR: plfile $plfile is missing"
  [ -f $p/$slfile ] || die "ERR: slfile $slfile is missing"
  ./slp $p/$plfile
  ./slp $p/$slfile
  echo "t $t"
done
