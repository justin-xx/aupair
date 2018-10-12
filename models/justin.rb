require 'singleton'
require 'json'

class Justin
  
  include Singleton
  
  attr_reader :house, :location
  
  def initialize
    @house = House.instance
    update_location(@house.location.lat, @house.location.lng)
  end

  def update_location(_lat,_lng)    
    # log all GPS locations a file for now
    `echo #{Time.now.to_i}--#{_lat},#{_lng} >> /home/pi/Documents/aupair/shared/locations.txt`
    
    # If you're not updating the location, don't bother
    return nil if !@location.nil? && @location.lat == _lat && @location.lng == _lng
    
    previously = outside_geofence    
            
    # Create the new location
    @location = Geokit::LatLng.new(_lat,_lng) 
    
    # Set @outside_geofence to nil, so next time instance function outside_geofence is called, the
    # distance from home will be re-calculated and cached
    @outside_geofence = nil
    
    puts "p: #{previously} n: #{outside_geofence}"
    
    # If there is a change in at-home or away status after the new coordinates
    if previously.nil? || (previously != outside_geofence)
      self.away=outside_geofence
    end
    puts
  end
  
  def outside_geofence
    @outside_geofence ||= calc_outside_geofence
  end
  
  def calc_outside_geofence
    return nil if @location.nil?
    @location.distance_to(@house.location) >= 0.5
  end
  
  def away
    @away ||= calc_outside_geofence
  end
  
  def lat
    location.lat
  end
  
  def lng
    location.lng
  end
  
  def away=(_status)
    @away = _status
    
    if @away
      puts "went away"      
      @house.set_away
    else      
      puts "got home"      
      @house.set_home
    end
    self
  end
  
  def to_json
    {
      location: [lat, lng],
      outside:   outside_geofence,
      away:      away
    }.to_json
  end
  
end
