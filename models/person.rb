class Person
  include Mongoid::Document
  
  field :name,     type: String
  
  has_many :locations, autosave: true
  
  def self.instance
    begin
      Person.all.map {|person| person}.first      
    rescue Exception => e
      puts "You need to do this first: Person.create(:name => '')"
      nil
    end
  end
  
  def house_location
    @location ||= Geokit::LatLng.new(39.606971391513575,-84.2195247487018)
  end

  def update_location(_lat,_lng)
    _prev_away = away
    
    _location = locations.build(lat: _lat, lng: _lng)
    
    return if _location.false_positive
    
    if _location.outside_geofence
      left_home if !_prev_away
    else
      arrived_home if _prev_away
    end 
    
    _location.save
  end
  
  def locations_for_day(time = Time.now)    
    locations.find({
      "time" => {
        "$gte" => timezone.local_to_utc(time.beginning_of_day).to_i, 
        "$lte" => timezone.local_to_utc(time.end_of_day).to_i
      }
    })    
  end

  def away
    locations.last.away
  end
  
  def awake=(_status)
    return if @awake == _status
    
    @awake = _status    
    @awake ? set_awake : set_asleep
  end
  
  def to_json
    {
      location: [lat, lng],
      outside:   outside_geofence,
      away:      away
    }.to_json
  end

  private
  
  ##
  # All of these private methods need to be added
  # to a resque-like queue. These functions should
  # still add these jobs to the queue
  
  def arrived_home
    HueBridge.instance.set_lights_to_recipe(:bright)
    # HueBridge.instance.set_outdoor_lights_to_recipe(:bright)
    # Add resque worker queue job to turn outside lights off in 15 minutes
    
    Thermostat.instance.away=false
    
    # Add resque worker queue job to turn televisions on
  end
  
  def left_home    
    HueBridge.instance.set_lights_to_off
    Thermostat.away=true
    # Add resque worker queue job to turn televisions off    
  end
  
  def set_awake
    HueBridge.instance.set_lights_to_recipe(:bright)
    # Add resque worker queue job to turn televisions on
    # Add resque worker queue job to thermostat to waking temp
  end
  
  def set_asleep
    HueBridge.instance.set_lights_to_off
    # Add resque worker queue job to thermostat to sleeping temp (-5 degrees?)        
    # Add resque worker queue job to turn televisions off    
    # Add resque worker queue job to close garage doors    
  end
  
end
