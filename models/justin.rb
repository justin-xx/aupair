require 'singleton'
require 'json'
require 'mongo'
require 'tzinfo'

class Justin
  
  include Singleton
  
  attr_reader :house, :location, :locations
  
  def initialize
    @db_locations = DATABASE[:locations]    
    @away = false
    @house = House.instance
    @location = Geokit::LatLng.new(@house.location.lat,@house.location.lng) 
  end
  
  # in miles
  def threshold_distance
    1.0
  end

  def update_location(_lat,_lng)
    _location = Geokit::LatLng.new(_lat,_lng) 
    
    return if !ignored_locations.detect {|ignored_location|
      _location.distance_to(ignored_location) <= 0.05
    }.nil?
    
    @db_locations.insert_one({
      time: Time.now.utc.to_i, 
      lat: _lat, 
      lng: _lng
    })
    
    @previous_location = @location
              
    # Create the new location
    @location = _location
    
    # Set @outside_geofence to nil, so next time instance function outside_geofence is called, the
    # distance from home will be re-calculated and cached
    @outside_geofence = nil
        
    # If there is a change in at-home or away status after the new coordinates
    distance_from_previous = @location.distance_to(@previous_location)
    
    if distance_from_home > threshold_distance
      self.away=true if !@away
    else
      self.away=false if @away
    end
  end
  
  def locations
    @locations = []
    @db_locations.find.each do |location|
      @locations << location
    end
    @locations
  end
  
  def locations_for_day(time = Time.now)    
    @db_locations.find({
      "time" => {
        "$gte" => timezone.local_to_utc(time.beginning_of_day).to_i, 
        "$lte" => timezone.local_to_utc(time.end_of_day).to_i
      }
    })    
  end  
  
  def outside_geofence
    @outside_geofence ||= calc_outside_geofence
  end
  
  def calc_outside_geofence
    distance_from_home >= threshold_distance
  end
  
  def distance_from_home
    @location.distance_to(@house.location)
  end
  
  def away
    @away ||= calc_outside_geofence
  end
  
  def lat
    @location.lat
  end
  
  def lng
    @location.lng
  end
  
  def timezone
    @timezone ||=  TZInfo::Timezone.get('America/New_York')
  end
  
  def away=(_status)
    @away = _status
    @away ? @house.set_away : @house.set_home      
    self
  end
  
  def to_json
    {
      location: [lat, lng],
      outside:   outside_geofence,
      away:      away
    }.to_json
  end
  
  private
  def ignored_locations    
    @ignored_locations ||= AUPAIR_CONFIG["ignore"].inject([]) do |memo, ignore_location|
      memo << Geokit::LatLng.new(ignore_location["lat"], ignore_location["lng"])
    end
  end
  
end
