#!/usr/bin/env python
# pip install libjpeg-dev
# -*- coding: utf-8 -*-

from datetime import datetime
import pytz

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
    f = open('/home/pi/Documents/aupair/current/lib/eye/processes/infoboard-current-conditions.pid', 'w')
    f.write(pid)
    f.close()

def font(size = 24, name = 'HelveticaNeue-01.ttf'):    
    #return ImageFont.truetype("/home/pi/Documents/aupair/current/lib/typefaces/{0}".format(name), size, encoding="utf-8");
    return ImageFont.truetype("/Users/justin/Documents/Code/aupair/lib/typefaces/{0}".format(name), size, encoding="utf-8");
#filename = '/home/pi/Documents/aupair/current/lib/infoboard/infoboard-current-conditions.png'
#writePidFile()
filename = '/Users/justin/Documents/Code/aupair/lib/infoboard/infoboard-current-conditions.png'

while True:
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        end

    current_conditions = r.json()['current_conditions']
    
    forecasts_by_day = r.json()['forecasts']['forecasts_by_day']

    img = Image.new('RGBA', (1920, 1080), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    # draw.text((0,0), str(temp), font=font(170),fill=(255, 255, 255, 255))
    #
    # draw.text((170,0), u"\u00b0", font=font(77),fill=(255, 255, 255, 255))
    #
    # draw.text((250,40), main, font=font(130),fill=(255, 255, 255, 255))

    ## HEADER
    draw.rectangle([(294.194,102.000), (294.194+464.531,102.000+90.113)],  (0, 0, 0, int(255*0.7)))

    draw.rectangle([(758.725,102.000), (758.725 +237.447,102.000+90.113)],  (0, 0, 0, int(255*0.5)))

    draw.text((376.945,115.111), current_conditions['city'], font=font(55),fill=(255, 255, 255, 255))

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))

    draw.text((801.455,115.111), localTime.strftime('%I:%M'), font=font(55),fill=(255, 255, 255, 255))

    ## MAIN CONTAINER

    draw.rectangle([(294.194,218.696), (294.194+1329.612,218.696+690.263)],  (127, 127, 127, int(255*0.4)))

    draw.rectangle([(294.194,218.696), (294.194+1329.612,218.696+690.263)],  (26, 26, 26, int(255*0.7)))
    
    
    img.save(filename, 'PNG')

    time.sleep(60)