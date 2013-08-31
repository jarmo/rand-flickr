require "flickr_api"
require "spec_helper"

describe FlickrApi do
  context "#initialize" do
    it "raises an error when API key is not provided" do
      expect {
        FlickrApi.new(nil, "foo")
      }.to raise_error("Flickr API key is not provided!")
    end

    it "raises an error when username is not provided" do
      expect {
        FlickrApi.new("key", nil)
      }.to raise_error("Flickr username is not provided!")
    end
  end

  context "#random_photo" do

  end

end
