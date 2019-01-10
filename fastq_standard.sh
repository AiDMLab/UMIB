#!/bin/bash
#$1 is the input file name
echo $1
#$2 is the output file name
echo $2

h=`awk '{print NR}' $1 |tail -n1`
if [ "${h}" > 2000 ]
 then
   let h=2000
 fi

for((p=1;p<=$h;p=p+4))
do
let q=p+4
l1=`cat $1 | tail -n +$p | head -n 1`
l2=`cat $1 | tail -n +$q | head -n 1`
if [ "${l1}" = "${l2}" ]
 then
   break
 else
   continue
 fi
echo $p
done

echo $p
let xx=p
tail -n +${xx} $1 > $2
