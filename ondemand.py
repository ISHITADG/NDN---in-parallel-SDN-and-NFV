import datetime
import time
timer=1
while True:
        with open("ondemand.txt", mode='w') as file:
                file.write('%s\n' %(timer/1))
        timer+=0
        time.sleep(2)
