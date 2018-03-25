server "pi", user: "pi", roles: %w{web}
role :web, %w{pi@pi}, my_property: :my_value

set :ssh_options, {
 keys: %w(/home/justin/.ssh/id_rsa),
 forward_agent: false,
 auth_methods: %w(publickey)
}

namespace :deploy do
  
  before :starting, :ensure_user do
    on roles(:web) do      
      execute "cd #{current_path}/lib/eye/processes; eye load ../aupair.eye; eye stop thin"
    end
  end
  
  
  desc "Install the build-essential apt package"
  task :install_build_essentials do
    on roles(:web) do
      sudo "apt-get update"
      sudo "apt-get install -y build-essential ruby-dev libcurl4-openssl-dev"
      sudo "gem install bundler"
    end
  end

  #before :deploy, "deploy:install_build_essentials"  

  task :bundle_install do
    on roles(:web) do      
      execute "cd #{release_path}; bundle install"
    end
  end

  after "deploy:updated", "deploy:bundle_install"
  
  task :start_thin do
    on roles(:web) do      
      execute "cd #{current_path}/lib/eye/processes; eye load ../aupair.eye; eye start thin"
    end
  end
  
  task :copy_server_sh do
    on roles(:web) do
      execute "ln -nfs #{shared_path}/start-server.sh #{current_path}/lib/eye/processes"
    end
  end
  
  after "deploy:finished", "deploy:start_thin"
  after "deploy:finished", "deploy:copy_server_sh"
end


