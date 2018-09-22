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
    when 'goodmorning'
      @house.goodmorning
    when 'goodnight'
      @house.goodnight
    when 'im_leaving'
      @house.set_away
    when 'im_home'
      @house.set_home
    when 'im_traveling'
      @house.set_travel
    when 'off'
      @house.set_lights_to_off
    when 'gaming'
      @house.set_office_gaming
    when 'tv'
      @house.set_living_room_tv
    else
      @house.set_lights_to_recipe(params['action'])
    end
  
    @house.to_json
  end

end