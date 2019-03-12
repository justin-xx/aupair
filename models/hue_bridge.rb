class HueBridge

  include Singleton
  
  attr_reader :client,
              :rooms,
              :lights,
              :motion_sensors
  
  def initialize
    @client         = Hue::Client.new(AUPAIR_CONFIG["hue"]["account"])
    @rooms          = @client.groups
    @lights         = @client.lights
    @motion_sensors = @client.motion_sensors    
  end
  
  def indoor_rooms
    @indoors ||= @rooms.reject {|room| room.name == "Outside"}
  end
  
  def outdoors
    @outdoors ||= @rooms.detect {|room| room.name == "Outside"}
  end
  
  def lights_off?
    @rooms.detect {|room| room.any_on} ? false : true
  end
  
  def set_lights_to_off
    self.lights.each do |light|
      light.set_to_off
    end
  end
  
  def set_outdoor_lights_to_off
    outdoors.lights.each do |light|
      light.set_to_off
    end
  end
  
  def set_lights_to_recipe(recipe = :bright)
    indoor_rooms.each do |room|
      room.lights.each do |light|
        light.set_to(recipe)        
      end
    end
  end
  
  def set_outdoor_lights_to_recipe(recipe = :bright)
    outdoors.lights.each do |light|
      light.set_to(recipe)
    end
  end
  
  def set_lights_brightness(percentage)
    indoor_rooms.each do |room|
      room.lights.each do |light|
        light.set_brightness(percentage)
      end
    end
  end
  
  # There is about a 12s timeout for the motion sensor to set presence to true, then go back to not  
  def detect_motion
    @client.motion_sensors.each do |sensor| 
      if sensor.name != 'HomeAway' && sensor.presence
        return true
      end
    end
    false
  end

end