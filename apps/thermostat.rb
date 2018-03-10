class ThermostatController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @thermostat = Thermostat.instance
    @thermostat.to_json
  end

end