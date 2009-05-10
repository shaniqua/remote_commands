require "capistrano/ext/multistage"

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

deploy.task :default do
  on_rollback { run "rm -rf #{release_path}; true" }
  strategy.deploy!
  symlink
  restart
end

deploy.task :restart do
  run "mkdir -p tmp"
  run "touch tmp/restart.txt"
end
