require 'singleton'
require 'json'

class Justin
  
  include Singleton
  
  attr_reader :home, :location, :lat, :lng
  
  def initialize
    @home = Geokit::LatLng.new(39.606932,-84.219543)
    @location = Geokit::LatLng.new(39.606932,-84.219543)
  end

  def update_location(_lat,_lng)
    puts "Updating Location\n#{_lat},#{_lng}"
    
    previously = away?
    
    @location = Geokit::LatLng.new(_lat,_lng)    
  
    _away = away?
    
    # If there is a change in at-home or away status after the new coordinates
    if previously != _away
      _away ? House.instance.set_away : House.instance.set_home
    end
  end
  
  def away?
    @home.distance_to(@location) >= 0.5
  end
  
  def to_json
    {
      location: [@location.lat, @location.lng],
      away: self.away?
    }.to_json
  end
  
end