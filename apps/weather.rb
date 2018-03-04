class WeatherController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @weather = Weather.instance
    @weather.to_json
  end

end