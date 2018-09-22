server "pi", user: "pi", roles: %w{web}
role :web, %w{pi@pi}

server "pi-test", user: "pi", roles: %w{web, test}
role :web, %w{pi@pi-test}

set :ssh_options, {
 keys: %w(/home/justin/.ssh/id_rsa),
 forward_agent: false,
 auth_methods: %w(publickey)
}

namespace :deploy do
  
  task :stop_aupair do
    on roles(:web) do
      execute "[ ! -e /home/pi/Documents/aupair/current ] && eye stop aupair; ls"
    end
  end
  
  task :checkout_raspidmx do
    on roles(:web) do
      execute "[ ! -e /home/pi/Documents/aupair/shared/raspidmx ] && git clone https://github.com/AndrewFromMelbourne/raspidmx.git /home/pi/Documents/aupair/shared/; ls"
    end
  end
  
  task :install_system_gems do
    on roles(:web) do
      sudo "gem install thin"
      sudo "gem install bundler"
      sudo "gem install eye"
    end    
  end
  
  task :setup_config do
    on roles(:web) do
      config = '{"features": {"weather": "true","nest": "true"},"weather": {"api": "eff657faed2487df","zip": "45342"},"hue": {"account":"justinrich"},"nest": {"email": "nest@justinrich.com","password": ".Trseoms1972"},"server": {"ip": "192.168.0.58","port": "8080","aupair-path": "/home/pi/Documents/aupair/current"}}'
      execute "touch #{shared_path}/config.json"
      execute "echo '#{config}' > #{shared_path}/config.json"
    end
  end
  
  desc "Install the build-essential apt package"
  task :install_build_essentials do
    on roles(:web) do
      sudo "apt-get update"
      sudo "apt-get install -y build-essential ruby-dev libcurl4-openssl-dev libcairo2-dev"
    end
  end
  
  task :bundle_install do
    on roles(:web) do      
      execute "cd #{release_path}; bundle install --deployment"
    end
  end
  
  task :symlink_raspidmx do
    on roles(:web) do      
      execute "ln -nfs #{shared_path}/raspidmx #{current_path}/lib/raspidmx"
    end
  end
  
  task :symlink_config do
    on roles(:web) do      
      execute "ln -nfs #{shared_path}/config.json #{current_path}/config/config.json"
    end
  end
  
  task :start_eye do
    on roles(:web) do      
      execute "eye load #{current_path}/lib/eye/aupair.eye; eye restart aupair"
    end
  end
  
  task :install_pip3_modules do
    on roles(:web) do
      execute "pip3 install pytz"
    end
  end

  before "deploy:starting", :stop_aupair    
  before "deploy:starting", :setup_config  
  before "deploy:starting", :install_system_gems
  before "deploy:starting", :checkout_raspidmx  
  before "deploy:starting", :install_build_essentials

  after "deploy:updated", :bundle_install
  after "deploy:symlink:release", :symlink_raspidmx
  after "deploy:symlink:release", :symlink_config

  after "deploy:finished", :start_eye
  after "deploy:finished", :install_pip3_modules
  
end

