require 'singleton'
require 'json'

class House
  
  include Singleton
  
  attr_reader :bridge
  
  attr_reader :rooms
  
  attr_reader :lights
  
  attr_reader :away
  
  attr_reader :travel
  
  def initialize
    @bridge = HueBridge.instance
    @rooms = @bridge.groups
    @lights = @bridge.lights
    @away = false
  end
  
  def goodmorning
    @home = true
    @travel = false
    
    set_lights_to_recipe('read')
    Television.instance.set_source
  end
  
  def goodnight
    @home = true
    @travel = false
    
    Television.instance.turn_display_off
    self.set_lights_to_off
  end
  
  def set_away
    @away = true
    @travel = false
    
    self.set_lights_to_off
    Television.instance.turn_display_off
  end
  
  def set_home
    @away = false
    @travel = false
    
    set_lights_to_recipe('bright')
    Television.instance.set_source
    set_office_gaming
  end
   
  def set_travel
    @away = true
    @travel = true
    
    Television.instance.turn_display_off
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
      light.set_state(gaming_attrs.update({:brightness => 200}))
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