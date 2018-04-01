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


filename = '/home/pi/Documents/aupair/current/lib/eye/tmp/infoboard-top-datetime.png'
writePidFile()

while True:
    img = Image.new('RGBA', (560, 200), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))

    draw.text((0,0), localTime.strftime('%I:%M'), font=font(170),fill=(255, 255, 255, 255))

    draw.text((450,50), localTime.strftime('%p'), font=font(77),fill=(255, 255, 255, 255))

    img.save(filename, 'PNG')

    time.sleep(60)
