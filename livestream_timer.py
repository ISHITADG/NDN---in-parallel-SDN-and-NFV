import datetime
import time
timer=0
while True:
	with open("livestream.txt", mode='w') as file:
    		file.write('%s\n' %(timer/2))
	timer+=2
	time.sleep(2)
