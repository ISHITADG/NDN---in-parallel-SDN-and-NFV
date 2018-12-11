##NDN
#After run
#Once: 
mkdir /users/ishitadg/NDN; mkdir /users/ishitadg/NDN/DASH_BUFFER; mkdir /users/ishitadg/NDN/BOLA_LOG/;

#Move all dash buffer log:
cd /users/ishitadg/NDN/DASH_BUFFER; sudo rm *;docker cp ndn0:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG0.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn1:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG1.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn2:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG2.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn3:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG3.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn4:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG4.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn5:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG5.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn6:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG6.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn7:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG7.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn8:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG8.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn9:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/DASH_BUFFER* DASH_BUFFER_LOG9.csv; sudo rm -rf ASTREAM_LOGS/;
#Move all bola log:
cd /users/ishitadg/NDN/BOLA_LOG; rm *;docker cp ndn0:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG0.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn1:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG1.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn2:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG2.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn3:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG3.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn4:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG4.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn5:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG5.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn6:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG6.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn7:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG7.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn8:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG8.csv; sudo rm -rf ASTREAM_LOGS/;docker cp ndn9:/mnt/QUIClientServer0/ASTREAM_LOGS/ .;sudo  mv ASTREAM_LOGS/BOLA_LOG* BOLA_LOG9.csv; sudo rm -rf ASTREAM_LOGS/;
#run pythonscript on results
cd /users/ishitadg/; rm NDN/abr*; rm 5_qoendn.py;wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoendn.py;python 5_qoendn.py;mv abr* NDN/;
#transfer
scp -r ishitadg@c220g1-030623.wisc.cloudlab.us:NDN ~/ResearchZink/ndn-results/NFV-NDN/512mb\ cache

##IP
mkdir /users/ishitadg/IP; mkdir /users/ishitadg/IP/DASH_BUFFER; mkdir /users/ishitadg/IP/BOLA_LOG/;
##
#Move all dash buffer log:
cd /users/ishitadg/IP/DASH_BUFFER; sudo rm *;cp /mnt/QUIClientServer0/ASTREAM_LOGS/DASH_BUFFER* .;
#Move all bola log:
cd /users/ishitadg/IP/BOLA_LOG; sudo rm *;cp /mnt/QUIClientServer0/ASTREAM_LOGS/BOLA_LOG* .;
#run pythonscript on results
cd /users/ishitadg/; rm IP/abr*; rm 5_qoeip.py; wget -L https://raw.githubusercontent.com/ISHITADG/NDN---in-parallel-SDN-and-NFV/master/5_qoeip.py; python 5_qoeip.py;mv abr* IP/;
#transfer
scp -r ishitadg@c220g1-030623.wisc.cloudlab.us:IP ~/ResearchZink/ndn-results/NFV-IP/
