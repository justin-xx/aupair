require File.expand_path('../../../../init', __FILE__)

map '/' do
  run MainController
end

map '/location' do
  run LocationController
end

map '/weather' do
  run WeatherController
end

map '/lights' do
  run LightsController
end

map '/tv' do
  run TelevisionController
end

map '/thermostat' do
 run ThermostatController
end