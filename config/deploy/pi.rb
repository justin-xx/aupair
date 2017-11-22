server "pi", user: "pi", roles: %w{web}
role :web, %w{pi@pi}, my_property: :my_value

set :ssh_options, {
 keys: %w(/home/justin/.ssh/justin_id_rsa),
 forward_agent: false,
 auth_methods: %w(publickey)
}

namespace :deploy do
  
  desc "Install the build-essential apt package"
  task :install_build_essentials do
    on roles(:web) do
      sudo "apt-get update"
      sudo "apt-get install build-essential ruby-dev libcurl4-openssl-dev"
    end
  end

  # before :deploy, "deploy:install_build_essentials"  

  task :bundle_install do
    on roles(:web) do
      execute "cd #{release_path}; bundle install"
    end
  end

  after "deploy:updated", "deploy:bundle_install"
end


