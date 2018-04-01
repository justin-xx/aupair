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

def center_text(draw, msg, ):
    w, h = draw.textsize(msg)
    
filename = '/home/pi/Documents/aupair/current/lib/infoboard/infoboard-five-day.png'
writePidFile()

while True:
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        end

    current_conditions = r.json()['current_conditions']
    print(int(current_conditions['temperature']))
    
    forecasts_by_day = r.json()['forecasts']['forecasts_by_day']
    print(forecasts_by_day)
    img = Image.new('RGBA', (1920, 1080), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    # draw.text((170,0), u"\u00b0", font=font(77),fill=(255, 255, 255, 255))
    
    ## HEADER
    draw.rectangle([(294.194,102.000), (294.194+464.531,102.000+90.113)],  (0, 0, 0, int(255*0.7)))

    draw.rectangle([(758.725,102.000), (758.725 +237.447,102.000+90.113)],  (0, 0, 0, int(255*0.5)))

    draw.text((376.945,115.111), current_conditions['city'], font=font(55),fill=(255, 255, 255, 255))

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))

    draw.text((801.455,115.111), localTime.strftime('%I:%M'), font=font(55),fill=(255, 255, 255, 255))

    ## MAIN CONTAINER

    # draw.rectangle([(294.194,218.696), (294.194+1329.612,218.696+690.263)],  (127, 127, 127, int(255*0.4)))

    ## FORECAST BUCKETS
    bucket_width  = 246.0008
    bucket_height = 690.263
    bucket_y_offset = 218.696
    
    x_offsets = [294.194,565.095,835.996,1106.897,1377.798]
    
    days_of_week_y_offset = 249.121
    days_of_week = ['NOW', forecasts_by_day[0]['weekday'], forecasts_by_day[1]['weekday'], forecasts_by_day[2]['weekday'], forecasts_by_day[3]['weekday']]
    
    highs_of_week_y_offset = 531.229
    highs_of_week = [str(int(current_conditions['temperature'])), forecasts_by_day[0]['high'], forecasts_by_day[1]['high'], forecasts_by_day[2]['high'], forecasts_by_day[3]['high']]
    
    lows_of_week_y_offset = 650.582
    lows_of_week = ['', forecasts_by_day[0]['high'], forecasts_by_day[1]['high'], forecasts_by_day[2]['high'], forecasts_by_day[3]['high']]
    
    conditions_of_week_y_offset = 736.091
    conditions_of_week = [current_conditions['weather'], forecasts_by_day[0]['conditions'], forecasts_by_day[1]['conditions'], forecasts_by_day[2]['conditions'], forecasts_by_day[3]['conditions']]
    
    for x_offset in x_offsets:    
        draw.rectangle([(x_offset,bucket_y_offset), (x_offset+bucket_width,bucket_y_offset+bucket_height)],  (26, 26, 26, int(255*0.7)))

    for index, day in enumerate(days_of_week):
        fnt      = font(70)
        msg      = str(day).upper()
        w, h     = draw.textsize(msg, font=fnt)
        x_offset = (bucket_width-w)/2 + x_offsets[index]
       
        draw.text((x_offset, days_of_week_y_offset), msg, align='center',font=fnt,fill=(255, 255, 255, 255))
    
    for index, high in enumerate(highs_of_week):
        fnt      = font(117)
        msg      = high
        w, h     = draw.textsize(msg, font=fnt)
        x_offset = (bucket_width-w)/2 + x_offsets[index]
       
        draw.text((x_offset, highs_of_week_y_offset), msg, align='center',font=fnt,fill=(255, 255, 255, 255))
    
    for index, low in enumerate(lows_of_week):
        fnt      = font(50)
        msg      = low
        w, h     = draw.textsize(msg, font=fnt)
        x_offset = (bucket_width-w)/2 + x_offsets[index]
       
        draw.text((x_offset, lows_of_week_y_offset), msg, align='center',font=fnt,fill=(255, 255, 255, 255))
        
    for index, conditions in enumerate(conditions_of_week):
        fnt      = font(46)
        words    = conditions.split()
        parts    = []
        
        for word in words:
            if word == "Thunderstorm":
                parts.append("Thunder\nstorm")
            else:
                parts.append(word)
            
        
        msg      = "\n".join(parts)
        w, h     = draw.textsize(msg, font=fnt)
        x_offset = (bucket_width-w)/2 + x_offsets[index]
       
        draw.text((x_offset, conditions_of_week_y_offset), msg, align='center',font=fnt,fill=(255, 255, 255, 255))
        
    img.save(filename, 'PNG')

    time.sleep(60*120)