class Thermostat
  
  include Singleton
  
  def initialize()
    @api_connection = set_api_connection
  end
  
  def current_temperature
    @api_connection.current_temperature
  end
  
  def target_temperature
    @api_connection.temperature
  end
  
  def target_temperature_high
    @api_connection.temperature_high
  end
  
  def target_temperature_low
    @api_connection.temperature_low
  end
  
  def target_temperature_at
    @api_connection.target_temperature_at
  end
  
  def away
    @api_connection.away
  end
  
  def away=(_status=true)
    @api_connection.away=_status
  end
  
  def humidity
    @api_connection.humidity
  end
  
  
  private
  
  def set_api_connection
    begin
      NestThermostat::Nest.new(email: 'nest@justinrich.com', password: '.Trseoms1972')
    rescue Exception => e
      nil
    end    
  end
end