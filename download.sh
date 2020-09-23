#!/bin/bash
files=(bunny_1032682bps bunny_1244778bps bunny_131087bps bunny_1546902bps bunny_178351bps bunny_2133691bps bunny_221600bps bunny_2484135bps bunny_262537bps bunny_3078587bps)
for f in ${files[@]}; do
        mkdir $f;
        for i in $(seq 299); do
                segname=$f$"_BigBuckBunny_2s"$i.m4s;
                python3 getfile.py -r bigbuckbunny -n /edu/umass/$f/$segname;
                mv $segname $f/;
        done
done
