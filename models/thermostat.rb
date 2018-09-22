require 'singleton'

class Thermostat
  
  include Singleton
  
  attr_reader :nest_api, :device_id, :structure_id, :user_id
  
  def initialize
    load_api_connection!
  end
  
  def status
    nest_api.status
  end
  
  def current_temperature
    nest_api.current_temperature
  end
  
  def target_temperature
    nest_api.temperature
  end
  
  def public_ip
    nest_api.public_ip
  end

  def leaf
    nest_api.leaf
  end

  def humidity
    nest_api.humidity
  end
  
  def away
    nest_api.away
  end
  
  def away=(_status=true)
    nest_api.away=_status
    nest_api.refresh_status
  end
  
  def hue_attributes    
    {
      current_temperature: current_temperature,
      target_temperature: target_temperature,
      public_ip: public_ip,
      leaf: leaf,
      humidity: humidity,
      user_id: user_id,
      structure_id: structure_id,
      device_id: device_id,
      away: away
    }
  end
  
  def to_json
    hue_attributes.to_json
  end
  
  private
  
  def load_api_connection!
    #'justin@justinrich.com' 'nXvyzqJtD54bEwT'
    @nest_api = NestThermostat::Nest.new(email: 'nest@justinrich.com', password: '.Trseoms1972', update_every: 900)   
    @user_id = nest_api.user_id
    @structure_id =  self.status['user'][user_id]['structures'][0].split('.')[1]
    @device_id = self.status['structure'][structure_id]['devices'][0].split('.')[1]
  end
  
end