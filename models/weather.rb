require 'singleton'
require 'json'


# https://radar.weather.gov/Conus/Loop/NatLoop.gif

class Weather

  include Singleton

  def initialize
    set_current_conditions
    set_forecast
  end

  def to_json
    {
      
      current_conditions:  self.current_conditions,
      current_temperature: self.current_temperature,
      forecast:            self.forecast
      
    }.to_json
  end
  
  def current_temperature
    c2f(k2c(self.current_conditions["main"]["temp"]))
  end
  
  def current_conditions
    if (Time.now - @current_conditions_set_at) > (60 * 15) # (1m = 60s)
      set_current_conditions
    end
    @current_conditions
  end

  
  def forecast
    if (Time.now - @forecast_set_at) > (60 * 15) # (1m = 60s)
      set_forecast
    end
    @forecast
  end
  
  private
  
  def set_current_conditions
    @current_conditions = JSON.parse(download_current_conditions)
    @current_conditions_set_at = Time.now.utc  
  end
  
  def download_current_conditions(_zip = '45342')
    `curl -u "justin@justinrich.com:CeeccicZadyat4I" \
          "http://api.openweathermap.org/data/2.5/weather?zip=#{_zip}&APPID=40ab86b4909f9e4e7519e4d5aecc65d0"`
  end
  
  def set_forecast
    @forecast = JSON.parse(download_forecast)
    @forecast_set_at = Time.now.utc   
  end
  
  def download_forecast(_zip = '45342')
    `curl -u "justin@justinrich.com:CeeccicZadyat4I" \
          "http://api.openweathermap.org/data/2.5/forecast?zip=#{_zip}&APPID=40ab86b4909f9e4e7519e4d5aecc65d0"`
  end
  
  def k2c(degrees)
    degrees.to_f - 273.15
  end
  
  
  def c2f(degrees)
    (degrees.to_f * 9.0 / 5 + 32).round(3)
  end
  
end
