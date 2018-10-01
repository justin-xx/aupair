require 'singleton'
require 'json'

class Justin
  
  include Singleton
  
  attr_reader :home, :location, :lat, :lng
  
  def initialize
    @home = Geokit::LatLng.new(39.606971391513575, -84.2195247487018)
    @location = Geokit::LatLng.new(39.606971391513575, -84.2195247487018)
  end

  def update_location(_lat,_lng)    
    puts Time.now
    puts "Updating Location\n#{_lat},#{_lng}"
    previously = away
    
    @location = Geokit::LatLng.new(_lat,_lng)    
    
    # Set @away to nil, so next time instance function away is called, the
    # distance from home will be re-calculated and cached
    @away = nil
    
    # If there is a change in at-home or away status after the new coordinates
    if previously != away
      away ? set_away : set_at_home
    end
    puts
  end
  
  def away
    @away ||= is_away
  end
  
  def is_away
    distance_from_home >= 0.03
  end
  
  def distance_from_home
    @home.distance_to(@location)
  end
  
  def set_at_home
    puts "got home"
    House.instance.set_home
  end
  
  def set_away
    puts "went away"
    House.instance.set_away
  end
  
  def to_json
    {
      location: [@location.lat, @location.lng],
      away: self.away
    }.to_json
  end
  
end