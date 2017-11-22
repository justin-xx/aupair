%w{hue}.each {|gem| require gem}

client = Hue::Client.new('justinrich')