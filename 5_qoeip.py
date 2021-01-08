#LEAP_quic
#!/bin/python

import datetime
import numpy as np
import pandas as pd
from itertools import cycle
import datetime as dt
import time
import dateutil
try:
    from StringIO import StringIO
except ImportError:
    from io import StringIO
#from StringIO import StringIO
import math
import glob
from pylab import *
import csv
#from itertools import izip
#import statsmodels.api as sm # recommended import according to the docs

bitrate_array =[]
cnt_of_switches = []
num_of_rebuffers = []
spectrum_array = []
DASH_BUFFER_FILENAME=glob.glob("/users/ishitadg/IP/DASH_BUFFER/DASH_BUFFER*")
#'<Absolute path of file, e.g /Users/10runs_sara_v*/dash_buffer*/DASH_BUFFER*>'
SERVER_LOG_FILENAME=glob.glob("/users/ishitadg/IP/BOLA_LOG/BOLA_LOG*")
#'<Absolute path of file, e.g /Users/10runs_sara_v*/dash_buffer*/SERVER_LOG*>'
#print(DASH_BUFFER_FILENAME)
#print(SERVER_LOG_FILENAME)

'''
Here we compute the rebuffering ratio using the following eqn.
((actual_playback_time-expected_playback_time)/expected_playback_time)*100
This computation uses the DASH_BUFFER_LOG file generated by the dash_buffer.py file in AStream
Here we use a video of length 299s.
'''

rebuf_arr = []
rebuf_file=[]
faultyclient=[]
i=0
for name in DASH_BUFFER_FILENAME:#glob.glob(DASH_BUFFER_FILENAME):
    list_quals=np.genfromtxt(name,delimiter=',', usecols=1, dtype=float)
    list_time=np.genfromtxt(name,delimiter=',', usecols=0, dtype=float)
    list_pbstate=np.genfromtxt(name,delimiter=',', usecols=3, dtype=str)
    #find last playback state and playback time
    list_quals=list_quals[~np.isnan(list_quals)]
    lastpbtime=list_quals[len(list_quals)-1]
    lastpbstate=list_pbstate[len(list_pbstate)-1]
    #if streaming is not complete, flag and ignore stats for this state
    if lastpbstate!="END":
        faultyclient.append(i)
        i=i+1
        print("!!!!!! INCOMPLETE PLAYBACK DETECTED. IGNORING STATS FOR CONTAINER: "+name+" !!!!!!")
        continue
    else:
        i=i+1
        if list_quals.size>5:
            rebuffering_perc = (list_time[len(list_time)-1] - lastpbtime)*100/ lastpbtime
            rebuf_arr.append(rebuffering_perc)
print("******* #CLIENTS w. INCOMPLETE STREAMING: "+str(len(faultyclient))+" OUT OF "+str(len(DASH_BUFFER_FILENAME))+" ********")
print("@@@@@@@@@@@ STREAMING QoE STATS @@@@@@@@@@")
print("Rebuffering %")
nparry2 = np.asarray(rebuf_arr)
avg_avgbr2=nparry2.mean()
sd_avgbr2=np.std(nparry2)
print(avg_avgbr2)
print(sd_avgbr2)
with open('abr_rebuffers_20Qualities-parallelIPforNDN.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(rebuf_arr)
f.close()

'''
API to compute spectrum as defined in the following paper:
Zink, Michael, Jens Schmitt, and Ralf Steinmetz. "Layer-encoded video in scalable adaptive streaming." 
IEEE Transactions on Multimedia 7.1 (2005): 75-84.
'''
def spectrum_calc(bitrate_history):

	# Modify this list to include all quality layers in your dataset
	bitrates = [1546902.0, 3526922.0, 89283.0, 221600.0, 262537.0, 791182.0, 334349.0, 595491.0, 1244778.0, 131087.0,178351.0, 2484135.0,1032682.0, 4219897.0]
	q_layer = []
	br_qlayer = {}
	for i in bitrates:
		q = i / 89283.0
		q_layer.append(q)
		br_qlayer.update({i:q})
	zh = 0
	zt = 0
	second_half_total = 0
	second_half = 0.0
	num_change = 0
	for j in range(1, len(bitrate_history)):
		if bitrate_history[j] != bitrate_history[j-1]:
			for i in range(1, len(bitrate_history)):
				if bitrate_history[i] != bitrate_history[i-1]:
					zh = zh + abs(bitrates.index(bitrate_history[i]) - bitrates.index(bitrate_history[i-1]))
					num_change = num_change + 1
			zzh = (1 / float(num_change)) * float(zh)

		
			ht = bitrates.index(bitrate_history[j])
			second_half = (ht - zzh) ** 2
			if bitrate_history[j] != bitrate_history[j-1]:
				zt = zt + second_half
	return zt

'''
Here we compute the number of switches by comparing the quality requested in every row with the previous row 
of a custom log file which we define as SERVER_LOG_<timestamp>.log in the dash_client.py file of the AStream player.
'''
i=0
for name in SERVER_LOG_FILENAME:#glob.glob(SERVER_LOG_FILENAME):	
        #ignore stats from clients that didn't end properly
        if i in faultyclient:
            i=i+1
            continue
        else:
            i=i+1
            f1=open(name)
	    lines = f1.readlines()[1:]
	    if len(lines)>5:
	    	#print len(lines)
		prev_row = None
		cnt=0
		sum=0.0
		mag_switches =0.0
		for line in lines:
			row1 = line.split(",")
			sum+=float(row1[2])
			if prev_row != None :
				if (prev_row[2] != row1[2]):
					cnt+=1
			prev_row = row1 
		cnt_of_switches.append(cnt)
		f1.close()

cnt_of_switches = np.asarray(cnt_of_switches)
avg_cntsw=cnt_of_switches.mean()
sd_cntsw=np.std(cnt_of_switches)
print("#Number of Switches")
print(avg_cntsw)
print(sd_cntsw)


with open('abr_numofswitches_20Qualities-parallelIPforNDN.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(cnt_of_switches)
f.close()
   

'''
Here we compute the average bitrate as a mathematical average of all the entries in the custom file 
SERVER_LOG_<timestamp.log> in the dash_client.py file of the AStream player. 
We also compute the spectrum for every client file by calling the spectrum calculator API defined above.
'''
i=0
for name in SERVER_LOG_FILENAME:#glob.glob(SERVER_LOG_FILENAME):
     #ignore stats from clients that didn't end properly
     if i in faultyclient:
         i=i+1
         continue
     else:
         i=i+1
         list_quals=np.genfromtxt(name,delimiter=',', usecols=2, dtype=float)
         list_time=np.genfromtxt(name,delimiter=',', usecols=0, dtype=float)
         spectrum_array.append(spectrum_calc(list_quals[1:]))
         if list_quals.size>5:
             x = list_quals[~np.isnan(list_quals)].mean()
             bitrate_array.append(x/1000000.0)
nparry = np.asarray(bitrate_array)
avg_avgbr=nparry.mean()
sd_avgbr=np.std(nparry)
print("Bitrate")
print(avg_avgbr)
print(sd_avgbr)
nparry2 = np.asarray(spectrum_array)
avg_avgspec=nparry2.mean()
sd_avgspec=np.std(nparry2)
print("Spectrum")
print(avg_avgspec)
print(sd_avgspec)

with open('abr_fullcap_rate_20Qualities-parallelIPforNDN.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(bitrate_array)
f.close()

with open('abr_spectrum_20Qualities-parallelIPforNDN.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(spectrum_array)
f.close()
