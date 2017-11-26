class MainController < Aupair::Base
  
  configure do
    set :views, Proc.new { File.join(File.dirname(__FILE__), "../views") }
  end
  
  get '/' do
    content_type :html
    @tv = Television.instance
    erb :television
  end

end