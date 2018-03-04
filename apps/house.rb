class HouseController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @house = House.instance
    @house.to_json
  end
  
  post '/' do
    @house = House.instance
      
    case params['action']
    when 'off'
      @house.set_lights_to_off
    when 'on'
      @house.set_lights_to_bright
    when 'dim'
      @house.set_lights_to_dim      
    when 'read'
      @house.set_lights_to_read
    when 'concentrate'
      @house.set_lights_to_concentrate
    end
  
    @house.to_json
  end

end