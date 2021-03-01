#!/bin/bash
files=(bunny_89283bps bunny_131087bps bunny_178351bps bunny_221600bps bunny_262537bps  bunny_334349bps bunny_595491bps bunny_791182bps bunny_1032682bps bunny_1244778bps bunny_1546902bps bunny_2484135bps bunny_3526922bps bunny_4219897bps)
for f in ${files[@]}; do
        mkdir $f;
        for ((i=1;i<=148;i++)); do
                segname=$f$"_BigBuckBunny_2s"$i.m4s;
                echo $"downloading..."$segname
		ndncatchunks --fast-conv --init-ssthresh 12 -vTD /edu/umass/$f/$segname > $segname 2>&1;
                mv $segname $f/;
        done
done
