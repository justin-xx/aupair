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


filename = '/home/pi/Documents/aupair/current/lib/eye/tmp/infoboard-top-weather.png'
writePidFile()

while True:
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        end
    
    temp = int(round(r.json()["current_temperature"]))
    main = r.json()["current_main_weather"]
    desc = r.json()["current_description"]

    img = Image.new('RGBA', (5, 200), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    draw.text((0,0), str(temp), font=font(170),fill=(255, 255, 255, 255))

    draw.text((170,0), u"\u00b0", font=font(77),fill=(255, 255, 255, 255))

    draw.text((250,40), main, font=font(130),fill=(255, 255, 255, 255))

    img.save(filename, 'PNG')
    
    time.sleep(60)