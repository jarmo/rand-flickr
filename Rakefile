require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc "Deploy to server"
task :deploy do
  sh %Q[git ls-files | rsync --delete --delete-excluded --prune-empty-dirs --exclude Rakefile --exclude .gitignore --exclude Guardfile --exclude .travis.yml --exclude "spec/*" --files-from - -avzhe ssh ./ jarmopertman.com:/home/jarmo/www/#{File.basename(__dir__)} && ssh jarmopertman.com "source /usr/local/share/chruby/chruby.sh; chruby ruby-2.0 && cd www/#{File.basename(__dir__)} && if [ -f rack.pid ]; then kill -9 \\$(cat rack.pid) || 1; rm rack.pid; fi && RACK_ENV=production rackup -s puma -p 6000 -o 127.0.0.1 -D -P rack.pid"]
end

task :default => :spec
