$: << File.expand_path("vendor/http_parser.rb-20", __dir__)
notification :ruby_gntp
interactor :off

guard 'rspec', version: 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'bundler' do
  watch('Gemfile')
end

guard 'livereload', host: "127.0.0.1" do
  watch(%r{views/.+\.(haml|scss)})
  watch(%r{public/.+\.(css|js)})
end
