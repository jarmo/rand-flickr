source "https://rubygems.org"
ruby File.read(File.expand_path('.tool-versions', __dir__)).strip.split(" ").last

gem "sinatra"
gem "haml"
gem "sass"
gem "faraday"
gem "rake"
gem "dotenv"

group :production do
  gem "puma"
  gem "foreman"
  gem "sentry-raven"
end

group :development do
  gem "thin"
  gem "guard"
  gem "guard-rspec"
  gem "guard-bundler"
  gem "guard-livereload"
  gem "wdm", platform: :mingw
  gem "win32console", platform: :mingw
  gem "ruby_gntp"
  gem "sinatra-contrib"
  gem "rack-livereload"
  gem "byebug"
end

group :test do
  gem "rspec"
  gem "webmock"
  gem "rack-test"
  gem "coveralls", require: false
  gem "simplecov", require: false
end
