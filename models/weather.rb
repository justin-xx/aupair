require 'singleton'
require 'json'


# https://radar.weather.gov/Conus/Loop/NatLoop.gif

class Weather

  include Singleton

  def initialize
    set_current_conditions
    set_hourly
    set_forecasts
  end
  
  def attributes
    {
      current_conditions: self.current_conditions,
      hourly: self.hourly,
      forecasts: self.forecasts
    }
  end
  
  def to_json
    self.attributes.to_json
  end
  
  def current_conditions
    if (Time.now.utc - @current_conditions_set_at) > (60 * 15) # (1m = 60s)
      set_current_conditions
    end
    @current_conditions
  end
  
  def forecasts
    if (Time.now.utc - @forecasts_set_at) > (60 * 120) # (1m = 60s)
      set_forecasts
    end
    @forecasts
  end
  
  def hourly
    if (Time.now.utc - @hourly_set_at) > (60 * 120) # (1m = 60s)
      set_hourly
    end
    @hourly
  end
  
  private
  
  def zip
    AUPAIR_CONFIG["weather"]["zip"]
  end
  
  def state
    "OH"
  end
  
  def download_json(_endpoint)
    `curl "http://api.wunderground.com/api/#{ AUPAIR_CONFIG["weather"]["api"]}/#{_endpoint}/q/#{state}/#{zip}.json"`
  end
  
  def download_current_conditions
    download_json('conditions')
  end
  
  def download_forecasts
    download_json('forecast')
  end
  
  def download_hourly
    download_json('hourly')
  end
  
  def set_current_conditions
    current_conditions_json = JSON.parse(download_current_conditions)
    
    conditions = current_conditions_json['current_observation']
      
    @current_conditions = {
      observed:    conditions['observation_epoch'],
      icon:        conditions['icon'],
      city:        conditions['display_location']['city'],
      zip:         conditions['display_location']['zip'],
      weather:     conditions['weather'],
      temperature: conditions['temp_f']
    }
    @current_conditions_set_at = Time.now.utc  
  end
  
  def set_forecasts
    forecasts_json = JSON.parse(download_forecasts)
        
    _days_and_evenings = forecasts_json['forecast']['txt_forecast']['forecastday'].inject([]) do |memo, forecastday|
      memo << {                           
          period:     forecastday['title'],               
          icon:       forecastday['icon'],
          forecast:   forecastday['fcttext'],
          pop:        forecastday['pop']
      }    
    end
        
    _forecasts_by_day = forecasts_json['forecast']['simpleforecast']['forecastday'].inject([]) do |memo, forecastday|
      memo << {
          epoch:      forecastday['date']['epoch'],
          time:       forecastday['date']['hour'],
          weekday:    forecastday['date']['weekday_short'],
          month:      forecastday['date']['monthname_short'],
          tz:         forecastday['date']['tz_short'],
          icon:       forecastday['icon'],
          high:       forecastday['high']['fahrenheit'],
          low:        forecastday['low']['fahrenheit'],
          conditions: forecastday['conditions']
      }
    end
    
    @forecasts = {
        days_and_evenings: _days_and_evenings,
        forecasts_by_day:  _forecasts_by_day
    }
    
    @forecasts_set_at = Time.now.utc   
  end
  
  def set_hourly
    hourly_json = JSON.parse(download_hourly)
          
    @hourly = hourly_json['hourly_forecast'].inject([]) do |memo, forecasthour|
      memo << {
        time:           forecasthour['FCTTIME']['civil'],
        temp:           forecasthour['temp']['english'],
        dewpoint:       forecasthour['dewpoint']['english'],
        conditions:     forecasthour['condition'], 
        icon:           forecasthour['icon'],
        icon_url:       forecasthour['icon_url'],
        wind_speed:     forecasthour['wspd']['english'],
        wind_direction: forecasthour['wdir']['dir'],
        humidity:       forecasthour['humidity'],
        snow:           forecasthour['snow']['english'],
        pop:            forecasthour['pop']
      }
    end
    
    @hourly_set_at = Time.now.utc  
  end
  
end
