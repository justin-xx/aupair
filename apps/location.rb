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
    parameters =  eval("#{params.first.first}")
    
    @person.update_location(
      parameters[:lat], 
      parameters[:lng], 
      parameters[:atHome]
    )    
    @person.to_json
  end
  
end