class TelevisionController < Aupair::Base
  
  post '/' do
    content_type :json
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