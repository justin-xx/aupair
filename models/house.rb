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