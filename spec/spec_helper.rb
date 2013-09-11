require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.color = true
end

ENV["FLICKR_API_KEY"] = "test-key"

