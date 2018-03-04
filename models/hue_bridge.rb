require 'singleton'
require 'json'

class HueBridge

  include Singleton

  def initialize
    @client = connect_to_bridge
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

  def client
    @client ||= connect_to_bridge
  end
  
  def to_json
    {
      address: @address,
      lights: @client.lights.collect {|light| light.hue_attributes}
    }.to_json
  end

  private

  def connect_to_bridge
    Hue::Client.new('justinrich')
  end
  
  def set_blooms(_hash = {})
    blooms = self.client.lights.find_all {|light| /Bloom/.match(light.name)}
    blooms.each do |bloom|
      bloom.set_state(_hash)
    end
    sleep 2
  end

  def set_lights(_hash = {})
    self.client.groups.each do |group|
      group.set_state(_hash)
    end
    sleep 5
  end
  
end

module Hue
  class Light
    def hue_attributes
      {
        identifier:        self.id,
        name:              self.name,
        hue:               self.hue,
        saturation:        self.saturation,
        brightness:        self.brightness,
        x:                 self.x, 
        y:                 self.y,         
        color_temperature: self.color_temperature,                 
        color_mode:        self.color_mode,                         
        type:              self.type,                                 
        model:             self.model
      }
    end
  end
end