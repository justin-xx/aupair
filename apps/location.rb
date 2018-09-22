class LocationController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @justin = Justin.instance
    @Justin.to_json
  end
  
  post '/' do
    @justin = Justin.instance
    @justin.update_location(params[:lat], params[:lng])
    @justin.to_json
  end
  
end