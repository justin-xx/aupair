require File.join(File.dirname(__FILE__), "init")

map '/' do
  run MainController
end

map '/tv' do
  run TelevisionController
end

map '/lights' do
  run LightsController
end
#
# map '/thermostat' do
#   run ThermostatController
# end