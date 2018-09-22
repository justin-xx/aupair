import subprocess
from threading import Timer

import os

def writePidFile():
    pid = str(os.getpid())
    f = open('/home/pi/Documents/aupair/current/lib/eye/processes/show-infoboard.pid', 'w')
    f.write(pid)
    f.close()


def filename(name):
    return "/home/pi/Documents/aupair/current/lib/infoboard/infoboard-{0}.png".format(name)

images_times = [['five-day',20],['current-conditions',20]]

writePidFile()

while True:
    
    for image_time in images_times:
        kill = lambda process: process.kill()
        os.environ["LD_LIBRARY_PATH"] = "/home/pi/Documents/aupair/shared/raspidmx/lib"        
        cmd = ['/home/pi/Documents/aupair/current/lib/raspidmx/pngview/pngview', '-l 3', filename(image_time[0])]
        proc = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        my_timer = Timer(image_time[1], kill, [proc])
    
        try:
            my_timer.start()
            stdout, stderr = proc.communicate()
        finally:
            pkill_cmd = ['sudo', '/usr/bin/pkill', 'pngview']
            pkill_proc = subprocess.Popen(
            pkill_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            pkill_stdout, pkill_stderr = pkill_proc.communicate()
            my_timer.cancel()
