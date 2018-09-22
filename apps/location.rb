class LocationController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @justin = Justin.instance
    @justin.to_json
  end
  
  post '/' do
    @justin = Justin.instance
    coordinates =  eval("#{params.first.first}")
    @justin.update_location(coordinates[:lat], coordinates[:lng])
    @justin.to_json
  end
  
end