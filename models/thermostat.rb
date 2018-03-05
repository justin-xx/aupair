require 'singleton'

class Thermostat
  
  include Singleton
  
  attr_reader :nest_api
  
  def initialize()
    @nest_api = set_api_connection
  end
  
  def current_temperature
    nest_api.current_temperature
  end
  
  def target_temperature
    nest_api.temperature
  end
  
  def target_temperature_high
    nest_api.temperature_high
  end
  
  def target_temperature_low
    nest_api.temperature_low
  end
  
  def target_temperature_at
    nest_api.target_temperature_at
  end
  
  def away
    nest_api.away
  end
  
  def away=(_status=true)
    nest_api.away=_status
  end
  
  def humidity
    nest_api.humidity
  end
  
  def to_json
    
  end
  
  private
  
  def set_api_connection
    NestThermostat::Nest.new(email: 'nest@justinrich.com', password: '.Trseoms1972')   
  end
end