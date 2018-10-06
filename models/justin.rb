require 'singleton'
require 'json'

class Justin
  
  include Singleton
  
  attr_reader :home, :location, :lat, :lng, :away
  
  def initialize
    update_location(home_lat, home_lng)
  end

  def update_location(_lat,_lng)    
    puts Time.now
    puts "Updating Location\n#{_lat},#{_lng}"
    
    @location = Geokit::LatLng.new(_lat,_lng)    
    
    previously = outside_geofence
    
    # Set @outside_geofence to nil, so next time instance function outside_geofence is called, the
    # distance from home will be re-calculated and cached
    @outside_geofence = nil
    
    # If there is a change in at-home or away status after the new coordinates
    if previously != outside_geofence
      self.away=outside_geofence
    end
    puts
  end
  
  def outside_geofence
    @outside_geofence ||= calc_outside_geofence
  end
  
  def calc_outside_geofence
    home.distance_to(@location) >= 0.5
  end
  
  def home
    @home ||= Geokit::LatLng.new(home_lat, home_lng)
  end
  
  def home_lat
    39.606971391513575
  end
  
  def home_lng
    -84.2195247487018
  end
  
  def away=(_status)
    @away = _status
    
    if @away
      puts "went away"      
      House.instance.set_away
      Thermostat.instance.away=true
    else      
      puts "got home"      
      House.instance.set_home
      Thermostat.instance.away=false
    end
    self
  end
  
  def to_json
    {
      location: [@location.lat, @location.lng],
      away: self.away
    }.to_json
  end
  
end