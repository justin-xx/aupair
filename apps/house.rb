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
    else
      @house.set_lights_to_recipe(params['action'])
    end
  
    @house.to_json
  end

end