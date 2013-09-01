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
          method: "flickr.urls.lookupUser",
          url: "http://www.flickr.com/photos/user"
        },
        {
          message: "User not found",
          stat: "fail"
        }
      )

      expect {
        api.random_photo
      }.to raise_error(FlickrApi::Error, "User not found")
    end

    it "raises an error if user does not have any photosets" do
      api_request(
        {
          method: "flickr.urls.lookupUser",
          url: "http://www.flickr.com/photos/user"
        },
        {
          user: {id: "valid-user-id"},
          stat: "ok"
        }
      )

      api_request(
        {
          method: "flickr.photosets.getList",
          user_id: "valid-user-id"
        },
        {
          photosets: {photoset: []},
          stat: "ok"
        }
      )

      expect {
        api.random_photo
      }.to raise_error(FlickrApi::Error, "User does not have any photosets")
    end

    it "ignores empty photosets" do
      api_request(
        {
          method: "flickr.urls.lookupUser",
          url: "http://www.flickr.com/photos/user"
        },
        {
          user: {id: "valid-user-id"},
          stat: "ok"
        }
      )

      api_request(
        {
          method: "flickr.photosets.getList",
          user_id: "valid-user-id"
        },
        {
          photosets: {photoset: [{photos: 0}]},
          stat: "ok"
        }
      )

      expect {
        api.random_photo
      }.to raise_error(FlickrApi::Error, "User does not have any photosets")
    end

    it "returns random photo from sets" do
      api_request(
        {
          method: "flickr.urls.lookupUser",
          url: "http://www.flickr.com/photos/user"
        },
        {
          user: {id: "valid-user-id"},
          stat: "ok"
        }
      )

      random_photoset = {photos: 2, id: "set-id3"}
      photosets = [
        {photos: 0, id: "set-id1"},
        {photos: 1, id: "set-id2"},
        random_photoset 
      ]

      api_request(
        {
          method: "flickr.photosets.getList",
          user_id: "valid-user-id"
        },
        {
          photosets: {
            photoset: photosets 
          },
          stat: "ok"
        }
      )

      random_photo = {id: "photo-id1", secret: "photo-secret", server: "photo-server", farm: 1337, title: "photo-title"}
      photos = [
        random_photo,
        {id: "photo-id2", secret: "photo-secret2", server: "photo-server2", farm: 42, title: "photo-title2"}
      ]

      api_request(
        {
          method: "flickr.photosets.getPhotos",
          media: "photos",
          photoset_id: "set-id3"
        },
        {
          photoset: {
            photo: photos
          },
          stat: "ok"
        }        
      )

      really_random_elements = [random_photoset, random_photo]
      Array.any_instance.stub(:sample) { really_random_elements.shift }

      expected_photo_with_url = random_photo.merge(
        photoset: random_photoset,
        :url=>"http://farm1337.staticflickr.com/photo-server/photo-id1_photo-secret_b.jpg"
      )

      api.random_photo.should == expected_photo_with_url
    end
  end

  def api_request(params, response_body)
    stub_request(:get, FlickrApi::API_ENDPOINT_URL.to_s)
      .with(query: hash_including(params))
      .to_return(:status => 200, :body => MultiJson.dump(response_body))      
  end
end
