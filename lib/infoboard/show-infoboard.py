import subprocess
from threading import Timer


def filename(name = 'weather'):
    return "/home/pi/Documents/aupair/current/lib/eye/tmp/infoboard-top-{0}.png".format(name)

images_times = [['weather',50], ['datetime', 10]]

while True:
    
    for image_time in images_times:
        kill = lambda process: process.kill()
        cmd = ['/home/pi/Documents/raspidmx/pngview/pngview', '-l 3', filename(image_time[0])]
        proc = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        my_timer = Timer(image_time[1], kill, [proc])
    
        try:
            my_timer.start()
            stdout, stderr = proc.communicate()
        finally:
            my_timer.cancel()