require 'singleton'
require 'json'

class Justin
  
  include Singleton
  
  attr_reader :house, :location, :lat, :lng
  
  def initialize
    @house = House.instance
    update_location(@house.location.lat, @house.location.lng)
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
    @location.distance_to(@house.location) >= 0.5
  end
  
  def away
    @away ||= calc_outside_geofence
  end
  
  def away=(_status)
    @away = _status
    
    if @away
      puts "went away"      
      @house.set_away
      Thermostat.instance.away=true
    else      
      puts "got home"      
      @house.set_home
    end
    self
  end
  
  def to_json
    {
      location: [@location.lat, @location.lng],
      away:      @away
    }.to_json
  end
  
end
