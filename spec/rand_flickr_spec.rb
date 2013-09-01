require "rand_flickr"
require "rack/test"
require "spec_helper"

describe RandFlickr do
  include Rack::Test::Methods

  it "/ redirects to the default user photo url" do
    FlickrApi.any_instance.stub(random_photo: {photoset: {id: "set-id"}, id: "photo-id"})
    get "/"
   
    last_response.should be_redirection
    last_response.location.should == "http://example.org/photo/jarm0/set-id/photo-id"
  end

  it "/photo/:user redirects to the photo url" do
    FlickrApi.any_instance.stub(random_photo: {photoset: {id: "set-id"}, id: "photo-id"})
    get "/photo/user"
   
    last_response.should be_redirection
    last_response.location.should == "http://example.org/photo/user/set-id/photo-id"
  end

  it "/photo/:user/:photoset_id/:photo_id renders photo from session when available" do
    get "/photo/user/set-id/photo-id", {}, {"rack.session" => {photo: "photo-from-session"}}
    last_response.body.should include("photo-from-session")
  end

  it "/photo/:user/:photoset_id/:photo_id renders photo from url" do
    FlickrApi.any_instance.stub(:photo).with("set-id", "photo-id").and_return("photo-from-url")
    get "/photo/user/set-id/photo-id"
    last_response.body.should include("photo-from-url")
  end

  def app
    RandFlickr
  end
end
