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
import textwrap
from PIL import Image, ImageDraw, ImageFont


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

def writePidFile():
    pid = str(os.getpid())
    f = open('/home/pi/Documents/aupair/current/lib/eye/processes/infoboard-current-conditions.pid', 'w')
    f.write(pid)
    f.close()

def font(size = 24, name = 'HelveticaNeue-01.ttf'):    
    return ImageFont.truetype("/home/pi/Documents/aupair/current/lib/typefaces/{0}".format(name), size, encoding="utf-8");
    

writePidFile()

while True:
    try:
        r = requests.get(url='http://192.168.0.58:8080/weather')
    except ConnectionError as e:
        end

    current_conditions = r.json()['current_conditions']
    
    forecasts_by_day = r.json()['forecasts']['forecasts_by_day']
    
    days_and_evenings = r.json()['forecasts']['days_and_evenings']

    filename = '/home/pi/Documents/aupair/current/lib/infoboard/infoboard-current-conditions.png'
    img = Image.new('RGBA', (1920, 1080), (255, 0, 0, 0))

    draw = ImageDraw.Draw(img)

    ## HEADER BUCKETS
    draw.rectangle([(294.194,102.000), (294.194+464.531,102.000+90.113)],  (0, 0, 0, int(255*0.5)))
    draw.rectangle([(783.725,102.000), (783.725+237.447,102.000+90.113)],  (0, 0, 0, int(255*0.3)))
    draw.rectangle([(1045.538,102.000), (1045.538+110.705,102.000+90.113)],  (0, 0, 0, int(255*0.3)))    

    # City
    draw.text((376.945,115.111), current_conditions['city'], font=font(55),fill=(255, 255, 255, 255))
    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))
    
    # Time
    time_msg = localTime.strftime('%I:%M')
    time_w, time_h = draw.textsize(time_msg, font=font(55))        
    draw.text((783.725+((237.447-time_w)/2),115.111), time_msg, align='center',font=font(55),fill=(255, 255, 255, 255))    
        
    # Temp
    temp_msg = str(int(current_conditions['temperature']))
    temp_w, temp_h = draw.textsize(temp_msg, font=font(55))    
    draw.text((1045.538+((110.705-temp_w)/2),115.111), temp_msg, align='center',font=font(55),fill=(255, 255, 255, 255))
    draw.text((1105.538+((110.705-temp_w)/2),115.111), u"\u00b0", font=font(55),fill=(255, 255, 255, 255))    
    
    
    ## FORECAST BUCKET
    bucket_width= 1331.605
    draw.rectangle([(292.879,275.217), (292.879+bucket_width,275.217+690.263)], (0, 0, 0, int(255*0.5)))
    
    # Icon
    icon_filepath = '/home/pi/Documents/aupair/current/lib/infoboard/weather/{0}.png'.format(icon_mappings[current_conditions['icon']])
    icon_file = Image.open(icon_filepath)    
    # 3rd param indicates alpha mask to use for first parameter
    img.paste(icon_file, (int(292.879+((444-icon_file.width)/2)), 379), icon_file)
    
    # Current Weather Left
    current_weather_msg = current_conditions['weather']
    current_weather_w, current_weather_h = draw.textsize(current_weather_msg, font=font(73))        
    draw.text((292.879+((444-current_weather_w)/2),580.889), current_weather_msg, align='center',font=font(73),fill=(255, 255, 255, 255))    
    
    # Overview
        
    for index, period in enumerate(days_and_evenings):
        if index != 1:
            continue
            
        pop_msg = "{0}% Chance\nof Rain".format(period['pop'])    
        pop_w, pop_h = draw.textsize(pop_msg, font=font(30))        
        draw.text((292.879+((444-pop_w)/2),687.702), pop_msg, align='center',font=font(30),fill=(255, 255, 255, 255))
        
        day_title = "TODAY"
        day_w, day_h = draw.textsize(day_title, font=font(43))
        draw.text((292.879+444,483.203), day_title, align='left',font=font(43),fill=(255, 255, 255, 255))                            
        
        draw.multiline_text((292.879+444,549.703), textwrap.fill(period['forecast'], 35), align='left', font=font(43),fill=(255, 255, 255, 255))
        break
    
    img.save(filename, 'PNG')
    
    time.sleep(60)