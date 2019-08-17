server "jar-server", user: "justin", roles: %w{web db}

#server "pi", user: "pi", roles: %w{television}
#
#server "pi-test", user: "pi", roles: %w{television}

set :ssh_options, {
 keys: %w(/home/justin/.ssh/id_rsa),
 forward_agent: false,
 auth_methods: %w(publickey)
}

set :deploy_to, "~/Documents/aupair"

namespace :deploy do
  
  task :stop_aupair do
    on roles(:web, :television) do
      execute "[ ! -e /home/#{:user}/Documents/aupair/current ] && eye stop aupair; ls"
    end
  end
  
  task :checkout_raspidmx do
    on roles(:television) do
      execute "[ ! -e /home/#{:user}/Documents/aupair/shared/raspidmx ] && git clone https://github.com/AndrewFromMelbourne/raspidmx.git /home/#{:user}/Documents/aupair/shared/; ls"
    end
  end
  
  task :install_system_gems do
    on roles(:web) do
      sudo "gem install thin"      
    end
    
    on roles(:web, :television) do
      sudo "gem install bundler"
      sudo "gem install eye"
    end    
  end
  
  task :setup_config do
    on roles(:web, :television) do
      config = '{"features": {"weather": "true","nest": "true"},"weather": {"api": "eff657faed2487df","zip": "45342"},"hue": {"account":"LiE6iDTdrB8mtz-Ixi1Wvy6bJaS4CI4YLXbBCChw"},"nest": {"id" :"09AA01AC36160LA1","email": "nest@justinrich.com","password": ".Trseoms1972"},"televisions": [{"ip": "192.168.0.58", "port": "3000"}],"mongodb": {"ip": "127.0.0.1","port":"27017","database": "aupair"},"google": {"maps": "AIzaSyCme2Y4zAOKbNfsESmta6B1niRKxBMLGMk"},"geofence":{"threshold": 1},"ignore": [{"lat": "39.59517841785846", "lng": "-84.23262744412749"},{"lat": "39.59428630746116", "lng": "-84.23107969980113"},{"lat": "39.59591350223986", "lng": "-84.23185221734772"},{"lat": "39.59500276600817", "lng": "-84.23038880420053"},{"lat": "39.610580","lng": "-84.203350"},{"lat": "39.59198368253506", "lng": "-84.23263985867557"}]}'
      execute "touch #{shared_path}/config.json"
      execute "echo '#{config}' > #{shared_path}/config.json"
    end
  end
  
  desc "Install the build-essential apt packages"
  task :install_build_essentials do
    on roles(:web) do
      sudo "apt-get update"
      sudo "apt-get install -y build-essential ruby-dev libcurl4-openssl-dev"
    end
    
    on roles(:television) do
      sudo "apt-get update"
      sudo "apt-get install -y build-essential ruby-dev libcurl4-openssl-dev libcairo2-dev"
    end
    
    on roles(:db) do
      sudo "apt-get update"
      sudo "apt-get install -y mongodb"
    end
  end
  
  task :bundle_install do
    on roles(:web) do      
      execute "cd #{release_path}; bundle install --deployment"
    end
  end
  
  task :symlink_raspidmx do
    on roles(:television) do      
      execute "ln -nfs #{shared_path}/raspidmx #{current_path}/lib/raspidmx"
    end
  end
  
  task :symlink_config do
    on roles(:web) do      
      execute "ln -nfs #{shared_path}/config.json #{current_path}/config/config.json"
    end
  end
  
  task :start_eye do
    on roles(:web, :television) do      
      execute "eye load #{current_path}/lib/eye/aupair.eye; eye restart aupair"
    end
  end
  
  task :install_pip3_modules do
    on roles(:television) do
      execute "pip3 install pytz"
    end
  end

  before "deploy:starting", :stop_aupair    
  before "deploy:starting", :setup_config  
  before "deploy:starting", :install_system_gems
  before "deploy:starting", :checkout_raspidmx  
  before "deploy:starting", :install_build_essentials

  after "deploy:updated",         :bundle_install
  after "deploy:symlink:release", :symlink_raspidmx
  after "deploy:symlink:release", :symlink_config

  after "deploy:finished", :start_eye
  after "deploy:finished", :install_pip3_modules
  
end

