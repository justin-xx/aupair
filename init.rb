%w{
  sinatra sinatra/base singleton json nest_thermostat hue eye geokit mongo tzinfo
}.each {|gem| require gem }


Dir[File.join(settings.root, "apps") + "/*.rb"].sort.each {|controller| require controller}
Dir[File.join(settings.root, "models") + "/*.rb"].sort.each {|model| require model}

AUPAIR_CONFIG = JSON.parse(
  File.read(
    File.join(settings.root, "config/config.json")
  )
)

DATABASE = Mongo::Client.new(
  [AUPAIR_CONFIG["mongodb"]["ip"] + ":" + AUPAIR_CONFIG["mongodb"]["port"]],
  :database => AUPAIR_CONFIG["mongodb"]["database"]
).database
