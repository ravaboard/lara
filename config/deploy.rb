# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'laravel'
set :repo_url, 'https://github.com/ravaboard/capistranas.git'
set :deploy_to, '/var/www'
# set:release_path,  { File.join(releases_path, release_name) }
set :scm, :git
set :pty, true
set :format, :pretty
set :keep_releases, 15
#set :release_path,  File.join(releases_path, release_name) 
#set :composer_install_flags, '--no-dev --no-interaction --optimize-autoloader'
#SSHKit.config.command_map[:composer] = "php -d memory_limit=512M -d allow_url_fopen=1 -d suhosin.executor.include.whitelist=phar /usr/local/bin/composer"
SSHKit.config.command_map[:composer] = 'php -d memory_limit=1G /usr/local/bin/composer'

namespace :deploy do
     
    desc "Build"
    after :updated, :build do
        on roles(:app) do
            within release_path  do
                execute :composer, "update" 
                execute :chmod, "u+x artisan"
				execute :php, "artisan clear-compiled"
                execute :php, "artisan optimize"
				execute :chmod, "-R 777 app/storage/cache"
                execute :chmod, "-R 777 app/storage/logs"
                execute :chmod, "-R 777 app/storage/meta"
                execute :chmod, "-R 777 app/storage/sessions"
                execute :chmod, "-R 777 app/storage/views"
				execute :php, "artisan migrate" # run migrations
            end
        end
    end
end

namespace :logs do

  desc "tail rails logs" 
  task :tail_rails do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 2 do
      execute "touch #{deploy_to}/sanity-check.txt"
    end
  end


desc "Running Composer Self-Update"
task :update do
  on roles(:app), in: :sequence, wait: 5 do
    if test "[", "-e", "/usr/local/bin/composer", "]"
      execute :composer, "self-update"
    else
      execute :curl, "-sS", "https://getcomposer.org/installer", "|", :php
      execute :mv, "composer.phar", "/usr/local/bin/composer"
    end
  end
end


desc "Running Composer Install"
task :install do
  on roles(:app), in: :sequence, wait: 5 do
    within current_path do
    execute :composer, "update -o --no-dev --quiet"
    end
  end
end



desc "Optimize Laravel Class Loader"
task :optimize do
  on roles(:app), in: :sequence, wait: 5 do
    within current_path do
      execute :php, "artisan clear-compiled"
      execute :php, "artisan optimize"
    end
  end
end

desc "Create a file"
 task :testing do
    on roles(:app), in: :sequence, wait: 2 do
      execute "touch #{File.join(current_path,'restart.txt')}"
    end
  end

end

