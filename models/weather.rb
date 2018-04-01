require 'singleton'
require 'json'


# https://radar.weather.gov/Conus/Loop/NatLoop.gif

class Weather

  include Singleton

  def initialize
    set_current_conditions
    set_forecasts
  end
  
  def attributes
    {
      current_conditions: self.current_conditions,
      forecasts: self.forecasts      
    }
  end
  
  def to_json
    self.attributes.to_json
  end
  
  def current_conditions
    if (Time.now - @current_conditions_set_at) > (60 * 15) # (1m = 60s)
      set_current_conditions
    end
    @current_conditions
  end
  
  def forecasts
    if (Time.now - @forecasts_set_at) > (60 * 120) # (1m = 60s)
      set_forecasts
    end
    @forecasts
  end
  
  private
  
  def download_current_conditions(_zip = '45342')
    `curl "http://api.wunderground.com/api/eff657faed2487df/conditions/q/OH/#{_zip}.json"`
  end
  
  def download_forecasts(_zip = '45342')
    `curl "http://api.wunderground.com/api/eff657faed2487df/forecast/q/OH/#{_zip}.json"`
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
  
end
