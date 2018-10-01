# config valid for current version and patch releases of Capistrano

set :application, "aupair"
set :repo_url, "git@github.com:justin-xx/aupair.git"

set :ssh_options, verify_host_key: :secure

set :deploy_to, "/home/pi/Documents/aupair"
