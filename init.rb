require 'sinatra'
require 'sinatra/base'
require 'json'
require 'singleton'
require 'nest_thermostat'


%w{
  sinatra sinatra/base singleton json nest_thermostat
}.each {|gem| require gem }


Dir[File.join(settings.root, "apps") + "/*.rb"].sort.each {|controller| require controller}
Dir[File.join(settings.root, "models") + "/*.rb"].sort.each {|model| require model}