require "uri"

class FlickrApi
  API_ENDPOINT_URL = URI.parse("http://api.flickr.com/services/rest/")

  def initialize(api_key, username)
    @api_key = api_key or raise "Flickr API key is not provided!"
    @username = username or raise "Flickr username is not provided!"
  end

  def random_photo
    photoset = random_photoset
    photos = response photoset_info(photoset[:id]), [], :photoset, :photo
    photo_with_info photoset, photos.sample
  end

  def photo(photoset_id, photo_id)
    photoset = photosets.find { |set| set[:id] == photoset_id }
    photos = response photoset_info(photoset[:id]), [], :photoset, :photo
    photo = photos.find { |photo| photo[:id] == photo_id }
    photo_with_info photoset, photo
  end

  private

  def user_id
    response request(method: "flickr.urls.lookupUser", url: "http://www.flickr.com/photos/#{@username}"), nil, :user, :id
  end

  def photosets
    response request(method: "flickr.photosets.getList", user_id: user_id), [], :photosets, :photoset
  end

  def photoset_info(photoset_id)
    request method: "flickr.photosets.getPhotos", photoset_id: photoset_id
  end

  def random_photoset
    ranked_sets = photosets.reduce([]) { |memo, set| memo += Array.new(set[:photos].to_i, set) }
    ranked_sets.shuffle.sample
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

  def response(json, default_value, *keys)
    json[:stat] != "ok" ? default_value : keys.reduce(json) { |memo, key| memo[key] }
  end
end
