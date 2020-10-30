#!/bin/bash
files=(bunny_4219897bps)
#files=(bunny_89283bps bunny_131087bps bunny_178351bps bunny_221600bps bunny_262537bps  bunny_334349bps bunny_595491bps bunny_791182bps bunny_1032682bps bunny_1244778bps bunny_1546902bps bunny_2484135bps bunny_3526922bps bunny_4219897bps)
seg1=BigBuckBunny_2s_init.mp4
seg2=BigBuckBunny_2snonSeg.mp4
for f in ${files[@]}; do
        segname1=$f$"_"$seg1;
        segname2=$f$"_"$seg2;
        echo $"downloading..."$segname1
        echo $"downloading..."$segname2
        ndncatchunks -qTD /edu/umass/$f/$segname1 > $segname1 2>&1;
        ndncatchunks -qTD /edu/umass/$f/$segname2 > $segname2 2>&1;
        mv $segname1 $f/;
        mv $segname2 $f/;
done
