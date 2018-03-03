require 'singleton'
require 'json'

class Weather

  include Singleton

  def initialize
    @current_conditions = self.current_conditions
    @forecast           = self.forecast
  end

  def to_json
    {
      current_conditions: self.current_conditions,
      forecast:           self.forecast
    }.to_json
  end
  
  def current_conditions
    JSON.parse(File.read("./lib/weather.json"))
  end
  
  def forecast
    JSON.parse(File.read("./lib/forecast.json"))
  end

  private

  def download_current_conditions(_zip = '45342')
    `curl -u "justin@justinrich.com:CeeccicZadyat4I" \
          "http://api.openweathermap.org/data/2.5/weather?zip=45040&APPID=40ab86b4909f9e4e7519e4d5aecc65d0" \ 
          > lib/weather.json`
  end
  
  def download_forecast(_zip = '45342')
    `curl -u "justin@justinrich.com:CeeccicZadyat4I" \
          "http://api.openweathermap.org/data/2.5/forecast?zip=45040&APPID=40ab86b4909f9e4e7519e4d5aecc65d0" \ 
          > lib/forecast.json`
  end
  
end
