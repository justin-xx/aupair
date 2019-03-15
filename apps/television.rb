class TelevisionController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @tv = Television.instance
    @tv.to_json
  end
  
  post '/on' do
    @tv = Television.instance.on
    @tv.to_json
  end
  
  post '/off' do
    @tv = Television.instance.off
    @tv.to_json
  end
  
end