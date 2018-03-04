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
  
end