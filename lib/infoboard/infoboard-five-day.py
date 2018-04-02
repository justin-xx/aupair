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
    
icon_mappings = {
    'chanceflurries': 'ModSnow',
    'chancerain': 'ModRain',
    'chancesleet': 'ModSleet',
    'chancesnow': 'ModSnow',
    'chancetstorms': 'CloudRainThunder',
    'clear': 'Clear',
    'cloudy': 'Cloudy',
    'flurries': 'ModSnow',
    'fog': 'Fog',
    'hazy': 'Mist',
    'mostlycloudy': 'PartlyCloudyDay',
    'mostlysunny': 'Sunny',
    'partlycloudy': 'PartlyCloudyDay',
    'partlysunny': '',
    'sleet': 'ModSleet',
    'rain': 'OccLightRain',
    'snow': 'HeavySnow',
    'sunny': 'Sunny',
    'tstorms': 'CloudRainThunder'     
}

filename = '/home/pi/Documents/aupair/current/lib/infoboard/infoboard-five-day.png'
writePidFile()

while True:
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        end

    current_conditions = r.json()['current_conditions']
    
    forecasts_by_day = r.json()['forecasts']['forecasts_by_day']
    print(forecasts_by_day)
    
    img = Image.new('RGBA', (1920, 1080), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    # draw.text((170,0), u"\u00b0", font=font(77),fill=(255, 255, 255, 255))
    
    ## HEADER
    draw.rectangle([(294.194,102.000), (294.194+464.531,102.000+90.113)],  (0, 0, 0, int(255*0.7)))

    draw.rectangle([(758.725,102.000), (758.725 +237.447,102.000+90.113)],  (0, 0, 0, int(255*0.5)))
    
    draw.rectangle([(996.538,102.000), (996.538 +110.705,102.000+90.113)],  (0, 0, 0, int(255*0.3)))    

    draw.text((376.945,115.111), current_conditions['city'], font=font(55),fill=(255, 255, 255, 255))

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))

    draw.text((801.455,115.111), localTime.strftime('%I:%M'), font=font(55),fill=(255, 255, 255, 255))
    
    draw.text((1013.286,115.111), str(int(current_conditions['temperature'])), font=font(55),fill=(255, 255, 255, 255))
    draw.text((1075.286,115.111), u"\u00b0", font=font(55),fill=(255, 255, 255, 255))
    
    ## MAIN CONTAINER

    # draw.rectangle([(294.194,218.696), (294.194+1329.612,218.696+690.263)],  (127, 127, 127, int(255*0.4)))

    ## FORECAST BUCKETS
    bucket_width  = 246.0008
    bucket_height = 690.263
    bucket_y_offset = 218.696
    
    x_offsets = [294.194,565.095,835.996,1106.897]#,1377.798]
    
    days_of_week_y_offset = 249.121
    days_of_week = [forecasts_by_day[0]['weekday'], forecasts_by_day[1]['weekday'], forecasts_by_day[2]['weekday'], forecasts_by_day[3]['weekday']]
    
    icons_of_week_y_offset = 326.118
    icons_of_week = [forecasts_by_day[0]['icon'], forecasts_by_day[1]['icon'], forecasts_by_day[2]['icon'], forecasts_by_day[3]['icon']]
    
    highs_of_week_y_offset = 560.229
    highs_of_week = [forecasts_by_day[0]['high'], forecasts_by_day[1]['high'], forecasts_by_day[2]['high'], forecasts_by_day[3]['high']]
    
    lows_of_week_y_offset = 679.582
    lows_of_week = [forecasts_by_day[0]['high'], forecasts_by_day[1]['high'], forecasts_by_day[2]['high'], forecasts_by_day[3]['high']]
    
    conditions_of_week_y_offset = 736.091
    conditions_of_week = [forecasts_by_day[0]['conditions'], forecasts_by_day[1]['conditions'], forecasts_by_day[2]['conditions'], forecasts_by_day[3]['conditions']]
    
    for x_offset in x_offsets:    
        draw.rectangle([(x_offset,bucket_y_offset), (x_offset+bucket_width,bucket_y_offset+bucket_height)],  (26, 26, 26, int(255*0.7)))

    for index, day in enumerate(days_of_week):
        fnt      = font(70)
        msg      = str(day).upper()
        w, h     = draw.textsize(msg, font=fnt)
        x_offset = (bucket_width-w)/2 + x_offsets[index]
       
        draw.text((x_offset, days_of_week_y_offset), msg, align='center',font=fnt,fill=(255, 255, 255, 255))
    
    for index, icon in enumerate(icons_of_week):
        #icon_filepath = '/home/pi/Documents/aupair/current/lib/infoboard/weather/{0}.png'.format(icon_mappings[icon])
        icon_filepath = '/Users/justin/Documents/Code/aupair/lib/infoboard/weather/{0}.png'.format(icon_mappings[icon])        
        icon_file = Image.open(icon_filepath)
        
        x_offset = int((bucket_width-icon_file.width)/2 + x_offsets[index]-15)
                
        # 3rd param indicates alpha mask to use for first parameter
        img.paste(icon_file, (x_offset, int(icons_of_week_y_offset)), icon_file)
    
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

    time.sleep(60)