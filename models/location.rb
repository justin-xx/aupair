class Location
  include Mongoid::Document
  
  field :lat,  type: BigDecimal
  field :lng,  type: BigDecimal
  field :away, type: Boolean
  field :distance_from_home, type: BigDecimal
  
  field :timezone,         type: String,   default: "America/New York"
  field :timestamp,        type: Integer,  default: Time.now.utc.to_i
  field :client_timestamp, type: DateTime

  belongs_to :person

  after_build   :calc_distance_from_home
  after_build   :update_timestamp

  def self.geofence_threshold_distance
    @threshold ||= AUPAIR_CONFIG ? AUPAIR_CONFIG["geofence"]["threshold"] : 1.0 # in miles
  end

  def lat_lng
    @lat_lng ||= Geokit::LatLng.new(lat, lng)
  end
  
  def false_positive
    !Location.false_positives.detect {|false_positive|
      lat_lng.distance_to(false_positive) <= 0.05
    }.nil?
  end
  
  def tz
    @tz ||=  TZInfo::Timezone.get(timezone)
  end
  
  def outside_geofence
    @outside_geofence ||= self.distance_away >= Location.geofence_threshold_distance
  end
  
  protected
      
  def self.false_positives
    @false_positives ||= AUPAIR_CONFIG["ignore"].inject([]) do |memo, ignore_location|
      memo << Geokit::LatLng.new(ignore_location["lat"], ignore_location["lng"])
    end
  end
  
  def distance_away
    distance_from_home || calc_distance_from_home
  end
  
  def calc_distance_from_home
    self.distance_from_home = lat_lng.distance_to(person.house_location)
  end
  
  def update_timestamp
    self.timestamp = Time.now.utc.to_i
  end

end