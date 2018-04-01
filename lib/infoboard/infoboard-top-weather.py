#!/usr/bin/env python
# pip install libjpeg-dev
# -*- coding: utf-8 -*-

import subprocess
from threading import Timer
from subprocess import STDOUT, check_output
import requests
import json
import sched, time
import os
from PIL import Image, ImageDraw, ImageFont

def writePidFile():
    pid = str(os.getpid())
    f = open('/home/pi/Documents/aupair/current/lib/eye/processes/infoboard-top-weather.pid', 'w')
    f.write(pid)
    f.close()

def font(size = 24, name = '/home/pi/Documents/aupair/current/lib/infoboard/HelveticaNeue.ttc'):
    return ImageFont.truetype(name, size, encoding="utf-8");

while True:
    filename = '/home/pi/Documents/aupair/current/lib/eye/tmp/infoboard-top-weather.png'
    writePidFile()
    
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        continue
        
    temp = int(round(r.json()["current_temperature"]))
    main = r.json()["current_main_weather"]
    desc = r.json()["current_description"]

    img = Image.new('RGBA', (1920, 1080), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    draw.rectangle(((0, 0), (1920, 360)), fill=(0, 0, 0, 100))

    draw.text((354.748/2, 254.766/2), str(temp), font=font(170),fill=(255, 255, 255, 255))

    draw.text((750.748/2, 300.766/2), u"\u00b0", font=font(77),fill=(255, 255, 255, 255))

    draw.text((850/2, 300.766/2), main, font=font(77),fill=(255, 255, 255, 255))
    draw.text((890/2, 470.766/2), desc, font=font(36),fill=(255, 255, 255, 255))

    img.save(filename, 'PNG')

    kill = lambda process: process.kill()
    cmd = ['/home/pi/Documents/raspidmx/pngview/pngview', '-l 3', filename]
    proc = subprocess.Popen(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    my_timer = Timer(60, kill, [proc])
        
    try:
        my_timer.start()
        stdout, stderr = proc.communicate()
    finally:
        my_timer.cancel()

    #/home/pi/Documents/raspidmx/pngview/pngview -l 3 /home/pi/Videos/infoboard.png