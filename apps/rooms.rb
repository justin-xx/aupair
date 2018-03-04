class RoomsController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @rooms = House.instance.rooms
    @rooms.collect {|room| room.hue_attributes}.to_json
  end
  
  get '/:id' do
    @rooms = House.instance.rooms.find {|room| room.id == params[:id]}
    @rooms.hue_attributes.to_json
  end
  
end