class MainController < Aupair::Base
  
  configure do
    set :views, Proc.new { File.join(File.dirname(__FILE__), "../views") }
  end
  
  get '/' do
    content_type :html
    erb :index
  end
  
  get '/map' do
    content_type :html
    
    day = params['day'] ? Time.parse(params['day']) : Time.now
    puts day
    @locations = Person.instance.locations_for_day(day)
    
    erb :map, :locals => {
      :locations => @locations,
      :api_key => AUPAIR_CONFIG["google"]["maps"]
    }
  end

end