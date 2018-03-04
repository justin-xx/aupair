require File.join(File.dirname(__FILE__), "../../../init")

map '/' do
  run MainController
end

map '/tv' do
  run TelevisionController
end

map '/house' do
  run HouseController
end

map '/lights' do
  run LightsController
end

map '/rooms' do
  run RoomsController
end
#
# map '/thermostat' do
#   run ThermostatController
# end