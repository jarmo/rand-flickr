require "uri"
require "faraday"
require "multi_json"
require "oj"

class FlickrApi
  API_ENDPOINT_URL = URI.parse("http://api.flickr.com/services/rest/")

  def initialize(api_key, username)
    @api_key = api_key or raise "Flickr API key is not provided!"
    @username = username or raise "Flickr username is not provided!"
  end

  def random_photo
    photoset = random_photoset
    photos = response photoset_info(photoset[:id]), :photoset, :photo
    photo_with_info photoset, photos.sample
  end

  def photo(photoset_id, photo_id)
    photoset = photosets.find { |set| set[:id] == photoset_id }
    photos = response photoset_info(photoset[:id]), :photoset, :photo
    photo = photos.find { |photo| photo[:id] == photo_id }
    photo_with_info photoset, photo
  end

  private

  def user_id
    response request(method: "flickr.urls.lookupUser", url: "http://www.flickr.com/photos/#{@username}"), :user, :id
  end

  def photosets
    all_photosets = response request(method: "flickr.photosets.getList", user_id: user_id), :photosets, :photoset
    all_photosets.delete_if { |set| set[:photos].to_i == 0 }
  end

  def photoset_info(photoset_id)
    request method: "flickr.photosets.getPhotos", media: "photos", photoset_id: photoset_id
  end

  def random_photoset
    ranked_sets = photosets.reduce([]) { |memo, set| memo += Array.new(set[:photos].to_i, set) }
    ranked_sets.shuffle.sample || raise_error("User does not have any photosets")
  end

  def photo_with_info(photoset={}, photo={})
    photo.merge(
      photoset: photoset,
      url: "http://farm#{photo[:farm]}.staticflickr.com/#{photo[:server]}/#{photo[:id]}_#{photo[:secret]}_b.jpg"
    )
  end

  def request(params={})
    conn = Faraday.new(:url => "#{API_ENDPOINT_URL.scheme}://#{API_ENDPOINT_URL.host}") do |c|
      c.adapter Faraday.default_adapter
    end

    response = conn.get(
      API_ENDPOINT_URL.path,
      params.merge(
        api_key: @api_key,
        format: "json",
        nojsoncallback: 1,
      )
    ).body

    json = MultiJson.load response, symbolize_keys: true
  end

  def response(json, *keys)
    json[:stat] == "fail" ? raise_error(json[:message]) : keys.reduce(json) { |memo, key| memo[key] }
  end

  def raise_error(error_message)
    raise Error, error_message
  end

  Error = Class.new(RuntimeError)

end
