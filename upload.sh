#!/bin/bash
for filename in /users/ishitadg/ndn-python-repo/examples/www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/*; do
        file=$(basename "$filename")
        #if file type is mpd, upload
        if [ ${file: -4} == ".mpd" ]
        then
                python3 putfile.py -r bigbuckbunny --register_prefix /edu/umass -f www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/$file  -n /edu/umass/$file
        fi
        #if file name starts with "bunny, then append n upload"
        if [[ $file == bunny* ]]
        then
                for seg in $filename/*; do
                        if [[ ${seg: -4} == ".m4s" ]] || [[ ${seg: -4} == ".mp4" ]] ;
                        then
                                segfile=$(basename "$seg")
                                segname=$file$"_"$segfile
                                python3 putfile.py -r bigbuckbunny --register_prefix /edu/umass -f www-itec.uni-klu.ac.at/ftp/datasets/DASHDataset2014/BigBuckBunny/2sec/$file/$segfile  -n /edu/umass/$file/$segname
                        fi
                done
        fi
done
