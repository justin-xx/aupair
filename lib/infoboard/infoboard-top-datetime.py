#!/usr/bin/env python
# pip install libjpeg-dev
# -*- coding: utf-8 -*-

from datetime import datetime
import pytz
import subprocess
from threading import Timer
from subprocess import STDOUT, check_output
import sched, time
import os
from PIL import Image, ImageDraw, ImageFont

def writePidFile():
    pid = str(os.getpid())
    f = open('/home/pi/Documents/aupair/current/lib/eye/processes/infoboard-top-datetime.pid', 'w')
    f.write(pid)
    f.close()

def font(size = 24, name = '/home/pi/Documents/aupair/current/lib/infoboard/HelveticaNeue.ttc'):
    return ImageFont.truetype(name, size, encoding="utf-8");


while True:
    filename = '/home/pi/Documents/aupair/current/lib/eye/tmp/infoboard-top-datetime.png'
    writePidFile()

    img = Image.new('RGBA', (1920, 1080), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))

    draw.text((2500/2, 254.766/2), localTime.strftime('%I:%M'), font=font(170),fill=(255, 255, 255, 255))

    draw.text((3400/2, 300.766/2), localTime.strftime('%p'), font=font(77),fill=(255, 255, 255, 255))

    img.save(filename, 'PNG')
    
    kill = lambda process: process.kill()
    cmd = ['/home/pi/Documents/raspidmx/pngview/pngview', '-l 4', filename]
    proc = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    my_timer = Timer(15*60, kill, [proc])
        
    try:
        my_timer.start()
        stdout, stderr = proc.communicate()
    finally:
        my_timer.cancel()

    #/home/pi/Documents/raspidmx/pngview/pngview -l 3 /home/pi/Videos/infoboard.png