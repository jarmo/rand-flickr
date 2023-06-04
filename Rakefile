if File.exist? "spec"
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
end

def app?
  File.exist? "config.ru"
end

def app_name
  "randflickr"
end

if app?
  desc "Restart app"
  task :restart => [:stop, :start]

  desc "Start app"
  task :start => :environment do
    sh %Q[sh -c 'RACK_ENV=production nohup bundle exec rackup -s puma -o 127.0.0.1 -P /var/run/#{app_name}.pid 1>>/var/log/#{app_name}/#{app_name}.log 2>&1 &']
  end

  desc "Stop app"
  task :stop => :environment do
    sh %Q[if [ -f /var/run/#{app_name}.pid ]; then kill -9 \$(cat /var/run/#{app_name}.pid) 2>/dev/null || echo "#{app_name} was not running..."; fi]
  end

  task :environment do
    Dir.chdir File.expand_path(File.dirname(__FILE__))
  end
end

task :default => :spec
