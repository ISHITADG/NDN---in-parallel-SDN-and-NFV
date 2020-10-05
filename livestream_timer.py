import datetime
import time
timer=0
while True:
	with open("ishita.txt", mode='w') as file:
                file.write('%s\n' %(timer/2))
        timer+=2
        python3 putfile.py -r bigbuckbunny --register_prefix /edu/umass -f ishita.txt -n /edu/umass/ishita.txt
	timer+=2
	time.sleep(2)
