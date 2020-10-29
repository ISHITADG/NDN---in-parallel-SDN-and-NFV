#!/bin/bash
files=(bunny_89283bps)
for f in ${files[@]}; do
        mkdir $f;
        for ((i=1;i<=299;i++)); do
                echo $"downloading..."$i
                if [[ $i -eq 500 ]] || [[ $i -eq 3100 ]] || [[ $i -eq 3600 ]]
                then
                        echo $"no"$i
                else
                        segname=$f$"_BigBuckBunny_2s"$i.m4s;
                        ndncatchunks -qTD /edu/umass/$f/$segname > $segname 2>&1;
                        mv $segname $f/;
                fi
        done
done
