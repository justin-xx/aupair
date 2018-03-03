class TelevisionController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @tv = Weather.instance
    @tv.to_json
  end
  
  post '/' do
    @tv = Television.instance
  
    case params['action']
    when 'set_source'
      @tv.set_source(params['source'])
    when 'turn_display_off'
      @tv.turn_display_off
    when 'turn_display_on'
      @tv.turn_display_on
    end
  
    @tv.to_json
  end

end

# curl -H "Content-Type: application/json" -X POST -d '{"action"