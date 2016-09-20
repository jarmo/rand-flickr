require "uri"
require "faraday"
require "json"

class FlickrApi
  API_ENDPOINT_URL = URI.parse("https://api.flickr.com/services/rest/")

  def initialize(api_key, username)
    @api_key = api_key or raise "Flickr API key is not provided!"
    @username = username or raise "Flickr username is not provided!"
  end

  def random_photo
    photoset = random_photoset
    photoset_with_info = photoset_info(photoset[:id])
    ownername = response photoset_with_info, :photoset, :ownername
    photos = response photoset_with_info, :photoset, :photo
    photo_with_info ownername, photoset, photos.sample
  end

  def photo(photoset_id, photo_id)
    photoset = photosets.find { |set| set[:id] == photoset_id }
    photoset_with_info = photoset_info(photoset[:id])
    ownername = response photoset_with_info, :photoset, :ownername
    photos = response photoset_with_info, :photoset, :photo
    photo = photos.find { |photo| photo[:id] == photo_id } or raise_error("Photo not found")
    photo_with_info ownername, photoset, photo
  end

  private

  def user_id
    json_response = request(method: "flickr.urls.lookupUser", url: "http://www.flickr.com/photos/#{@username}")
    raise Error::UserNotFoundError, "Flickr user #{@username} not found!" if json_response[:stat] == "fail" && json_response[:code] == 1
    response json_response, :user, :id
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
    ranked_sets.shuffle.sample || (raise Error::NoPhotosetsError, "Flickr user #{@username} does not have any photosets!")
  end

  def photo_with_info(ownername, photoset={}, photo={})
    photo.merge(
      ownername: ownername,
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

    json = JSON.parse(response, symbolize_names: true)
  end

  def response(json, *keys)
    json[:stat] == "fail" ? raise_error(json[:message]) : keys.reduce(json) { |memo, key| memo[key] }
  end

  def raise_error(error_message)
    raise Error, error_message
  end

  Error = Class.new(RuntimeError)
  Error::UserNotFoundError = Class.new(Error)
  Error::NoPhotosetsError = Class.new(Error)

end
