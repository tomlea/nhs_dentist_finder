set :application, "teeth"
set :repository,  Dir.pwd
set :deploy_via, :copy

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

role :app, "cwninja.com"
role :web, "cwninja.com"
role :db, "cwninja.com"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Link config files from server side shared path."
  task :link_site_config do
    run "for F in #{shared_path}/config/*; do ln -sf $F #{release_path}/config/; done"
  end

  task :install_gems do
    run "cd #{current_path} && sudo rake gems:install"
  end

  desc "write the crontab file"
  task :write_crontab, :roles => :app do
    run "cd #{release_path} && whenever --write-crontab"
  end
end

after "deploy:update_code" do
  deploy.link_site_config
end
