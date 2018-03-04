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
  
  def set_lights_to_concentrate
    set_lights({
        :on => true,
        :saturation => 254,
        :brightness => 254, 
        :color_temperature => 233, 
        :colormode => "ct"
    })
  
    set_blooms({
      :sat => 25,
      :hue => 46920
    })
  end

  def set_lights_to_bright
    set_lights({
        :on => true,
        :saturation => 254,
        :brightness => 254, 
        :color_temperature => 300, 
        :colormode => "ct"
    })
    
    set_blooms({
      :sat => 25,
      :hue => 46920
    })
  end

  def set_lights_to_read
    set_lights({
        :on => true,
        :saturation => nil,
        :brightness => 220, 
        :color_temperature => 343, 
        :colormode => "ct"
    })
  
    set_blooms({
      :sat => 25,
      :hue => 46920
    })
  end

  def set_lights_to_dim
    set_lights({
        :on => true, 
        :brightness => 62, 
        :color_temperature => 447, 
        :colormode => "ct"
    })
  
    set_blooms({
      :sat => 25,
      :hue => 46920
    })
  end

  def set_lights_to_off
    set_lights({:on => false})
  end
  
  def to_json
    {
      lights: self.lights.collect {|light| light.hue_attributes},
      rooms: self.rooms.collect {|room| room.hue_attributes}
    }.to_json
  end
  
  private
  
  def set_blooms(_hash = {})
    blooms = self.lights.find_all {|light| /Bloom/.match(light.name)}
    blooms.each do |bloom|
      bloom.set_state(_hash)
    end
    sleep 2
  end

  def set_lights(_hash = {})
    self.rooms.each do |room|
      room.set_state(_hash)
    end
    sleep 2
  end
  
  
end