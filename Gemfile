source "https://rubygems.org"
ruby "2.0.0"

gem "sinatra"
gem "haml"
gem "sass"
gem "faraday"
gem "multi_json"
gem "oj"

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
end
