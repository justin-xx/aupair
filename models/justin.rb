require 'singleton'
require 'json'

class Justin
  
  include Singleton
  
  attr_reader :location, :lat, :lng
  
  def initialize
    @home = Geokit::LatLng.new(39.606932,-84.219543)
    @location = Geokit::LatLng.new(39.606932,-84.219543)
  end

  def update_location(_lat,_lng)
    puts "Updating Location\n#{_lat},#{_lng}"
    @location = Geokit::LatLng.new(_lat,_lng)
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