require 'singleton'
require 'json'

class House
  
  include Singleton
  
  attr_reader :bridge
  
  attr_reader :rooms
  
  attr_reader :lights
  
  def initialize
    @bridge = HueBridge.instance
    @rooms = @bridge.groups
    @lights = @bridge.lights
  end
  
  def set_office_gaming
    
    gaming_attrs = {
      :on => true,
      :saturation => nil,
      :color_temperature => 343, 
      :colormode => "ct"
    }
    
    ["Office Table Lamp Right", "Office Table Lamp Left"].each do |light_name|
      light = self.lights.detect {|light| light.name == light_name}
      next unless light
      light.set_state(gaming_attrs.update({:brightness => 55}))
    end
    
    ["Office Lightstrip Monitor", "Office rear"].each do |light_name|
      light = @lights.detect {|light| light.name == light_name}
      next unless light
      light.set_state(gaming_attrs.update({:brightness => 220}))
    end
    
  end
  
  def set_living_room_tv
    tv_attrs = {
      :on => true, 
      :color_temperature => 447, 
      :colormode => "ct"
    }
    
    ["Stairs down"].each do |light_name|
      light = self.lights.detect {|light| light.name == light_name}
      next unless light
      light.set_off
    end
    
    ["Living Room Table Lamp 1", "Living Room Table Lamp 2", "Stairs up", "Kitchen lightstrip", "Oven range", ""].each do |light_name|
      light = self.lights.detect {|light| light.name == light_name}
      next unless light
      light.set_state(tv_attrs.update({:brightness => 20}))
    end
    
    ["TV", "TV lightstrip 2"].each do |light_name|
      light = @lights.detect {|light| light.name == light_name}
      next unless light
      light.set_state(tv_attrs.update({:brightness => 62}))
    end
    
    ["Living Room Bloom 1", "Living Room Bloom 2"].each do |light_name|
      light = @lights.detect {|light| light.name == light_name}
      next unless light
      light.set_recipe("Bright")
    end
  end
  
  def set_lights_to_recipe(recipe = 'bright')
    self.lights.each do |light|
      light.set_recipe(recipe)
    end
  end

  def set_lights_to_off
    self.lights.each do |light|
      light.set_off
    end
  end
  
  def to_json
    {
      lights: self.lights.collect {|light| light.hue_attributes},
      rooms: self.rooms.collect {|room| room.hue_attributes}
    }.to_json
  end
  
end