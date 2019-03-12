require '../../init.rb'

@bridge = HueBridge.instance

# If motion is detected and all of the lights in the house are off    
if @bridge.detect_motion && @bridge.lights_off?  
  hour = Time.now.hour

  case hour
  when 0..6
    # Nightlight
    @bridge.set_lights_to_recipe("dim")
  when 7..20
    @bridge.set_lights_to_recipe("bright")
  when 20..24
    # Nightlight
    @bridge.set_lights_to_recipe("dim")
  end
end

