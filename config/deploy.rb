$:.unshift File.expand_path("./lib", ENV["rvm_path"])

require "rvm/capistrano"
require "bundler/capistrano"

set :application, "citizentry"

set :rvm_ruby_string, "ree"
set :rails_env, :production

set :repository, "git://github.com/Freeport-Metrics/citizenry.git"
set :deploy_to, "/var/www/citizenry"
set :scm, :git
set :keep_releases, 5
set :deploy_via, :remote_cache

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :user, "citizenry"

role :web, "citizenry.freeportmetrics.com"
role :app, "citizenry.freeportmetrics.com"
role :db, "citizenry.freeportmetrics.com", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, "tmp", "restart.txt")}"
  end

  namespace :config do
    task :symlink, :roles => :app, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
    end
  end
end

after "deploy:finalize_update", "deploy:config:symlink"