class LightsController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @bridge = HueBridge.instance
    @bridge.to_json
  end
  
  post '/' do
    @bridge = HueBridge.instance
  
    case params['action']
    when 'off'
      @bridge.set_lights_to_off
    when 'on'
      @bridge.set_lights_to_bright
    when 'dim'
      @bridge.set_lights_to_dim      
    when 'turn_display_read'
      @bridge.set_lights_to_read
    end
  
    @bridge.to_json
  end

end