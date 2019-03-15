require 'singleton'
require 'json'

class Television

  include Singleton
  
  def on
    post_to_televisions('on')
  end
  
  def off
    post_to_televisions('off')
  end  

  def to_json
    get_televisions.to_json
  end

  private
  
  def post_to_televisions(cmd)
    AUPAIR_CONFIG["televisions"].each do |television|    
      television_api_request(television["ip"], television["port"], cmd, "POST")
    end
  end
  
  def get_televisions
    AUPAIR_CONFIG["televisions"].inject([]) do |televisions, television|    
      televisions << television_api_request(television["ip"], television["port"], nil, "GET")
    end
  end
  
  def television_api_request(ip, port, cmd, method)
    begin
      `curl -s -X #{method} http://#{ip}:#{port}/#{cmd}`      
    rescue Exception => e
      puts "And error has occurred"
    end
  end

end
