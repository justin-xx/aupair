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
    'clear': 'Sunny',
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
    'tstorms': 'CloudRainThunder',
    'nt_chanceflurries': 'IsoSnowSwrsNight',
    'nt_chancerain': 'IsoRainSwrsNight',
    'nt_chancesleet': 'ModSleetSwrsNight',
    'nt_chancetstorms': 'PartCloudRainThunderNight',
    'nt_chancesnow': 'IsoSnowSwrsNight',
    'nt_clear': 'Clear',
    'nt_cloudy': 'Overcast',
    'nt_flurries': 'IsoSnowSwrsNight',
    'nt_fog': 'Fog',
    'nt_hazy': 'Mist',
    'nt_mostlycloudy': 'Overcast',
    'nt_mostlysunny': 'Sunny',
    'nt_partlycloudy': 'PartlyCloudyNight',
    'nt_partlysunny': 'PartlyCloudyNight',
    'nt_sleet': 'ModSleetSwrsNight',
    'nt_rain': 'ModRainSwrsDay',
    'nt_snow': 'ModSnowSwrsNight',
    'nt_sunny': 'Sunny',
    'nt_tstorms': 'PartCloudRainThunderNight',
    'nt_cloudy': 'Overcast',
    'nt_partlycloudy': 'PartlyCloudyNight'   
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

    ##
    ## HEADER
    ##
    
    
    ## HEADER BUCKETS
    draw.rectangle([(294.194,102.000), (294.194+464.531,102.000+90.113)],  (0, 0, 0, int(255*0.5)))

    draw.rectangle([(783.725,102.000), (783.725+237.447,102.000+90.113)],  (0, 0, 0, int(255*0.5)))

    draw.rectangle([(1045.538,102.000), (1045.538+110.705,102.000+90.113)],  (0, 0, 0, int(255*0.5)))    
    
    draw.rectangle([(1182.581,102.000), (1182.581+441.962,102.000+90.113)],  (0, 0, 0, int(255*0.5)))        

    # CITY
    draw.text((376.945,115.111), current_conditions['city'], font=font(55),fill=(255, 255, 255, 255))

    localTime = datetime.now().replace(tzinfo=pytz.utc).astimezone(pytz.timezone('America/New_York'))
    
    # TIME
    time_msg = localTime.strftime('%I:%M')
    time_w, time_h = draw.textsize(time_msg, font=font(55))    
    
    draw.text((783.725+((237.447-time_w)/2),115.111), time_msg, align='center',font=font(55),fill=(255, 255, 255, 255))    
        
    # TEMP
    temp_msg = str(int(current_conditions['temperature'])) + u"\u00b0"
    temp_w, temp_h = fourday_draw.textsize(temp_msg, font=font(55))
    fourday_draw.text((1050.538+((110.705-temp_w)/2),115.111), temp_msg, align='center',font=font(55),fill=(255, 255, 255, 255))
        
    # CURRENT CONDITIONS
    draw.text((1303.0715,115.111), current_conditions['weather'], align='left',font=font(55),fill=(255, 255, 255, 255))
    
    icon_filepath = '/home/pi/Documents/aupair/current/lib/infoboard/weather/{0}.png'.format(icon_mappings[current_conditions['icon']])
    icon_file = Image.open(icon_filepath)
    icon_file.thumbnail([83,61], Image.ANTIALIAS)
    x_offset = int((110.4905-icon_file.width)/2 + 1182.581)
    img.paste(icon_file, (x_offset, 115), icon_file)
    
    
    
    
    ## FORECAST BUCKET
    bucket_x_offset = 294.194
    bucket_width= 1331.605
    bucket_height= 202
    
    bucket_y_offsets = [220.5, 464.64, 708.78]
    for bucket_y_offset in bucket_y_offsets:    
        draw.rectangle([(bucket_x_offset,bucket_y_offset), (bucket_x_offset+bucket_width,bucket_y_offset+bucket_height)], (0, 0, 0, int(255*0.7)))
    
    
    icon_y_offsets = [229.5, 495.264, 730.22]
    icon_size = [151, 159]
    
    period_title_x_offset = 686.188
    period_title_y_offsets = [242.164, 505.922, 744.728]
    
    period_titles = ["Tonight", "Tomorrow", "Tomorrow Night"]


    forecast_y_offsets = [283.729,544.487,783.292]
    
    # # Current Weather Left
    # current_weather_msg = current_conditions['weather']
    # current_weather_w, current_weather_h = draw.textsize(current_weather_msg, font=font(73))
    # draw.text((292.879+((444-current_weather_w)/2),580.889), current_weather_msg, align='center',font=font(73),fill=(255, 255, 255, 255))
    #
    # Overview
        
    for index, period in enumerate(days_and_evenings):
        if index == 0:
            continue
        
        if index > 3:
            continue


        icon_filepath = '/home/pi/Documents/aupair/current/lib/infoboard/weather/{0}.png'.format(icon_mappings[period['icon']])
        icon_file = Image.open(icon_filepath)    
        icon_file.thumbnail(icon_size, Image.ANTIALIAS)
        # 3rd param indicates alpha mask to use for first parameter
        img.paste(icon_file, (int(bucket_x_offset+((444-icon_file.width)/2)), int(icon_y_offsets[index-1])), icon_file)
                

        period_title_msg = period_titles[index-1]
        period_title_w, period_title_h = draw.textsize(period_title_msg, font=font(23, 'HelveticaNeue-Light-08.ttf'))
        draw.text((period_title_x_offset, period_title_y_offsets[index-1]), period_title_msg, align='left',font=font(23, 'HelveticaNeue-Light-08.ttf'),fill=(255, 255, 255, 255))

        draw.multiline_text((period_title_x_offset,forecast_y_offsets[index-1]), textwrap.fill(period['forecast'], 50), align='left', font=font(32),fill=(255, 255, 255, 255))

    img.save(filename, 'PNG')
    
    time.sleep(60)