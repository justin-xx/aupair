# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, "aupair"
set :repo_url, "git@github.com:justin-xx/aupair.git"

set :ssh_options, verify_host_key: :secure

set :deploy_to, "/var/www/aupair"
