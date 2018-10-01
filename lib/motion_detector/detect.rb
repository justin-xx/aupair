require '../../init.rb'

house = House.instance

# If motion is detected and all of the lights in the house are off    
if house.detect_motion #&& house.lights_off?
  puts "Motion detected and lights are off"
  
  hour = Time.now.hour

  case hour
  when 0..6
    # Nightlight
    house.set_lights_to_recipe("dim")
  when 7..20
    house.set_lights_to_recipe("bright")
  when 20..24
    # Nightlight
    house.set_lights_to_recipe("dim")
  end
end

