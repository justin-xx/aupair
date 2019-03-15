class ThermostatController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @thermostat = Thermostat.instance
    @thermostat.to_json
  end
  
  post '/target-temperature' do
    @thermostat = Thermostat.instance
    @thermostat.target_temperature=params[:temperature].to_i
    @thermostat.to_json
  end
  
end