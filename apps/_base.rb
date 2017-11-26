module Aupair
  # Setup sinatra configuration
  class Base < Sinatra::Base
    # configure do
    #   set :bind, '0.0.0.0'
    #   set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }
    # end
  end
end