# Application name
set :application, "ircurls"

# Deployment

set :runner, "irc-urls.net"
set :user, "irc-urls.net"
set :deploy_to, "/home/irc-urls.net/rails/#{application}"
set :keep_releases, 3
set :use_sudo, false
set :deploy_via, :remote_cache

# SCM
set :repository,  "git@github.com:hannu/irc-urls.git"
set :scm, :git
set :branch, "master"
set :git_enable_submodules, 1

role :app, "www.irc-urls.net", :primary => true
role :web, "www.irc-urls.net", :primary => true
role :db,  "www.irc-urls.net", :primary => true

task :after_symlink do
  run "ln -nfs #{shared_path}/images/urlimg #{release_path}/public/images/urlimg"
end

namespace :deploy do
  task :restart do
    run "cd #{current_path} && touch tmp/restart.txt"
    run "cd #{release_path}; export RAILS_ENV=production; script/delayed_job restart"
  end
  
  desc "Create urlimg directory"
  task :after_setup do
    run "mkdir -p #{shared_path}/images/urlimg"
  end

  task :after_update_code do
    #run "cd #{release_path} ; export RAILS_ENV=production; rake gems:install; rake db:migrate"
    run "find #{release_path}/public -type d -exec chmod 0755 {} \\;"
    run "find #{release_path}/public -type f -exec chmod 0644 {} \\;"
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
require 'bundler/capistrano'
