require 'singleton'
require 'json'
require 'mongo'

class Justin
  
  include Singleton
  
  attr_reader :house, :location, :locations
  
  def initialize
    @db = Mongo::Client.new(
      [ "#{AUPAIR_CONFIG["mongodb"]["ip"]}:#{AUPAIR_CONFIG["mongodb"]["port"]}" ], 
      :database => AUPAIR_CONFIG["mongodb"]["database"] 
    )
    @db_locations = @db[:locations]
    
    @house = House.instance
    update_location(@house.location.lat, @house.location.lng)
  end

  def update_location(_lat,_lng)    
    @db_locations.insert_one({
      time: Time.now.utc.to_i, 
      lat: _lat, 
      lng: _lng
    })
    
    # If you're not updating the location, don't bother
    return nil if !@location.nil? && @location.lat == _lat && @location.lng == _lng
    
    previously = outside_geofence    
            
    # Create the new location
    @location = Geokit::LatLng.new(_lat,_lng) 
    
    # Set @outside_geofence to nil, so next time instance function outside_geofence is called, the
    # distance from home will be re-calculated and cached
    @outside_geofence = nil
        
    # If there is a change in at-home or away status after the new coordinates
    if previously.nil? || (previously != outside_geofence)
      self.away=outside_geofence
    end
    puts
  end
  
  def locations
    @locations = []
    @db_locations.find.each do |location|
      @locations << location
    end
    @locations
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
