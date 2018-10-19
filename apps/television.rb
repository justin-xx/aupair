class TelevisionController < Aupair::Base
  
  before do
    content_type :json
  end
  
  get '/' do
    @tv = Television.instance
    @tv.to_json
  end
  
  post '/' do
    @tv = Television.instance
  
    case params['action']
    when 'set_source'
      @tv.set_source(params['source'])
    when 'turn_display_off'
      @tv.turn_display('off')
    when 'turn_display_on'
      @tv.turn_display('on')
    end
  
    @tv.to_json
  end

end