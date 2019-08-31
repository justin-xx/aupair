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
    coordinates =  eval("#{params.first.first}")
    @person.update_location(coordinates[:lat], coordinates[:lng])
    @person.to_json
  end
  
end