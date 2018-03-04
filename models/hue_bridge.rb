require 'singleton'
require 'json'

class HueBridge

  include Singleton

  attr_reader :client
  
  def initialize
    @client = connect_to_bridge
  end
  
  def groups
    @rooms ||= self.client.groups
  end
  
  def lights
    @lights ||= self.client.lights
  end
  
  def to_json
    {
      address: @address,
      lights: self.lights.collect {|light| light.hue_attributes},
      groups: self.groups.collect {|room| room.hue_attributes}
    }.to_json
  end

  private

  def connect_to_bridge
    Hue::Client.new('justinrich')
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
  
  class Group
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
        type:              self.type
      }
    end
  end
end