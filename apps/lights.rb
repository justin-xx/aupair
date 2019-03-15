class LightsController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @lights = HueBridge.instance.lights
    @lights.collect {|light| light.hue_attributes}.to_json
  end
  
  get '/:id' do
    @light = HueBridge.instance.lights.find {|light| light.id == params[:id]}
    @light.hue_attributes.to_json
  end
  
  post '/off' do
    HueBridge.instance.set_lights_to_off
    HueBridge.instance.set_outdoor_lights_to_off
    HueBridge.instance.to_json
  end
  
  post '/recipe' do
    HueBridge.instance.set_lights_to_recipe(params[:name].to_sym)
    HueBridge.instance.to_json
  end
  
  post '/brightness' do
    HueBridge.instance.set_lights_brightness(params[:percentage])
    HueBridge.instance.to_json
  end
  
end