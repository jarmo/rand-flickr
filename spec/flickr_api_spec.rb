require "flickr_api"
require "spec_helper"

describe FlickrApi do
  context "#initialize" do
    it "raises an error when API key is not provided" do
      expect {
        FlickrApi.new(nil, "user")
      }.to raise_error("Flickr API key is not provided!")
    end

    it "raises an error when username is not provided" do
      expect {
        FlickrApi.new("key", nil)
      }.to raise_error("Flickr username is not provided!")
    end
  end

  context "#random_photo" do
    let(:api) { FlickrApi.new "key", "user" }

    it "raises an error if user_id is not found" do
      api_request(
        {
          api_key: "key",
          method: "flickr.urls.lookupUser",
          url: "http://www.flickr.com/photos/user"
        },
        %q[{"stat": "fail", "message": "User not found"}]
      )

      expect {
        api.random_photo
      }.to raise_error(FlickrApi::Error, "User not found")
    end

    def api_request(params, response_body)
      stub_request(:get, FlickrApi::API_ENDPOINT_URL.to_s)
        .with(query: hash_including(params))
        .to_return(:status => 200, :body => response_body)      
    end
  end

end
