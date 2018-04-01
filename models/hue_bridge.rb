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
    Bright = {
      :on => true,
      :saturation => 254,
      :brightness => 254, 
      :color_temperature => 300, 
      :colormode => "ct"
    }
    
    BloomBright = {
      :on => true,
      :sat => 25,
      :hue => 46920
    }
    
    Brightdim = {
      :on => true,
      :saturation => 254,
      :brightness => 153, 
      :color_temperature => 300, 
      :colormode => "ct"
    }
    
    BloomBrightdim = {
      :on => true,
      :sat => 25,
      :hue => 46920,
      :brightness=>153
    }
    
    Concentrate = {
      :on => true,
      :saturation => 254,
      :brightness => 254, 
      :color_temperature => 233, 
      :colormode => "ct"
    }
    
    BloomConcentrate = {
      :on => true,
      :sat => 25,
      :hue => 46920,
      :brightness=>254
    }
    
    Dim = {
      :on => true, 
      :brightness => 62, 
      :color_temperature => 447, 
      :colormode => "ct"
    }
    
    BloomDim  = {
      :on => true,
      :sat => 25,
      :hue => 46920,
      :brightness => 62
    }
    
    Read = {
      :on => true,
      :saturation => nil,
      :brightness => 220, 
      :color_temperature => 343, 
      :colormode => "ct"
    }
    
    BloomRead = {
      :on => true,
      :sat => 25,
      :hue => 46920
    }
    
    
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
    
    def set_recipe(recipe = 'Bright')
      recipe_name = !self.bloom? ? recipe.capitalize : 'Bloom' + recipe.capitalize
      puts recipe_name
      attrs = Hue::Light.const_get(recipe_name)
      puts attrs
      self.set_state(attrs)  
    end
    
    def set_off
      self.set_state({:on => false})
    end
    
    
    def bloom?
      /Bloom/.match(self.name) || /Color light/.match(self.type)
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