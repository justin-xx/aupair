class LocationController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @person = Person.instance
    @person.to_json
  end
  
  post '/' do
    @person = Person.instance
    
    @person.update_location(
      params[:lat], 
      params[:lng], 
      params[:wifi]
    )    
    
    @person.to_json
  end
  
end