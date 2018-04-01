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
    f = open('/home/pi/Documents/aupair/current/lib/eye/processes/infoboard-five-day.pid', 'w')
    f.write(pid)
    f.close()

def font(size = 24, name = 'HelveticaNeue-01.ttf'):    
    return ImageFont.truetype("/home/pi/Documents/aupair/current/lib/typefaces/{0}".format(name), size, encoding="utf-8");

filename = '/home/pi/Documents/aupair/current/lib/infoboard/infoboard-five-day.png'
writePidFile()

while True:
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        end

    temp = int(round(r.json()["current_temperature"]))
    main = r.json()["current_main_weather"]
    desc = r.json()["current_description"]

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

    draw.text((376.945,115.111), "Miamisburg", font=font(55),fill=(255, 255, 255, 255))

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))

    draw.text((801.455,115.111), localTime.strftime('%I:%M'), font=font(55),fill=(255, 255, 255, 255))

    ## MAIN CONTAINER

    draw.rectangle([(294.194,218.696), (294.194+1329.612,218.696+690.263)],  (127, 127, 127, int(255*0.4)))

    ## FORECAST BUCKETS

    draw.rectangle([(294.194,218.696), (294.194+246.008,218.696+690.263)],  (26, 26, 26, int(255*0.7)))

    draw.rectangle([(565.095,218.696), (565.095+246.008,218.696+690.263)],  (26, 26, 26, int(255*0.7)))

    draw.rectangle([(835.996,218.696), (835.996+246.008,218.696+690.263)],  (26, 26, 26, int(255*0.7)))

    draw.rectangle([(1106.897,218.696), (1106.897+246.008,218.696+690.263)],  (26, 26, 26, int(255*0.7)))

    draw.rectangle([(1377.798,218.696), (1377.798+246.008,218.696+690.263)],  (26, 26, 26, int(255*0.7)))

    # DAYS OF WEEK

    draw.text((342.347,249.121), "SUN", font=font(70),fill=(255, 255, 255, 255))

    draw.text((603.523,249.121), "MON", font=font(70),fill=(255, 255, 255, 255))

    draw.text((890.695,249.121), "TUE", font=font(70),fill=(255, 255, 255, 255))

    draw.text((1149.932,249.121), "WED", font=font(70),fill=(255, 255, 255, 255))

    draw.text((1428.500,249.121), "THU", font=font(70),fill=(255, 255, 255, 255))

    # HIGHS

    draw.text((358.626,531.229), "49", font=font(117),fill=(255, 255, 255, 255))

    draw.text((629.528,531.229), "49", font=font(117),fill=(255, 255, 255, 255))

    draw.text((901.591,531.229), "73", font=font(117),fill=(255, 255, 255, 255))

    draw.text((1170.833,531.229), "60", font=font(117),fill=(255, 255, 255, 255))

    draw.text((1441.935,531.229), "46", font=font(117),fill=(255, 255, 255, 255))


    # LOW

    draw.text((376.533,634.582), "36", font=font(81),fill=(255, 255, 255, 255))

    draw.text((649.036 ,634.582), "31", font=font(81),fill=(255, 255, 255, 255))

    draw.text((920.372,634.582), "47", font=font(81),fill=(255, 255, 255, 255))

    draw.text((1189.13,634.582), "34", font=font(81),fill=(255, 255, 255, 255))

    draw.text((1460.182,634.582), "28", font=font(81),fill=(255, 255, 255, 255))

    # MULTILINE

    draw.text((376.533,634.582), "36", font=font(81),fill=(255, 255, 255, 255))

    draw.multiline_text((327.441,736.091), "Rain And\nSnow", fill=None, font=font(46), anchor=None, spacing=5, align="center")

    draw.multiline_text((598.341,736.091), "Rain And\nSnow", fill=None, font=font(46), anchor=None, spacing=5, align="center")

    draw.multiline_text((869.876,736.091), "Scattered\nThunder\nStorms", fill=None, font=font(46), anchor=None, spacing=5, align="center")

    draw.multiline_text((1150.161,736.091), "Showers", fill=None, font=font(46), anchor=None, spacing=5, align="center")

    draw.multiline_text((1436.077,736.091), "Partly\nCloudy", fill=None, font=font(46), anchor=None, spacing=5, align="center")

    img.save(filename, 'PNG')

    time.sleep(60)