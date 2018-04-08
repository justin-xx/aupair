require 'singleton'

class Thermostat
  
  include Singleton
  
  attr_reader :nest_api, :device_id, :structure_id, :status, :user_id
  
  def initialize
    load_api_connection!
  end
  
  def current_temperature
    c2f(status["shared"][self.device_id]["current_temperature"])
  end
  
  def target_temperature
    c2f(status["shared"][self.device_id]["target_temperature"])
  end
  
  def public_ip
    status["track"][self.device_id]["last_ip"].strip
  end

  def leaf
    status["device"][self.device_id]["leaf"]
  end

  def humidity
    status["device"][self.device_id]["current_humidity"]
  end
  
  def away
    status["structure"][structure_id]["away"]
  end
  
  def away=(_status=true)
    nest_api.away=_status   
    load_api_connection!     
  end
  
  def hue_attributes
    load_api_connection!
    
    {
      current_temperature: current_temperature,
      target_temperature: target_temperature,
      public_ip: public_ip,
      leaf: leaf,
      humidity: humidity,
      user_id: user_id,
      structure_id: structure_id,
      device_id: device_id
    }
  end
  
  def to_json
    hue_attributes.to_json
  end
  
  private
  
  def c2f(degrees)
    (degrees.to_f * 9.0 / 5 + 32).round(3)
  end
  
  def load_api_connection!
    if (Time.now.utc - (@updated_at || Time.at(0))) > (60 * 15)
      @nest_api = NestThermostat::Nest.new(
        email: AUPAIR_CONFIG["nest"]["email"], 
        password: AUPAIR_CONFIG["nest"]["password"]
      )   
      
      @status = nest_api.status
      @user_id = nest_api.user_id
      @structure_id =  status['user'][user_id]['structures'][0].split('.')[1]
      @device_id = status['structure'][structure_id]['devices'][0].split('.')[1]
      @updated_at = Time.now.utc
    end
  end
  
end