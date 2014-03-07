require "sinatra"
require "haml"
require "sass"
require File.expand_path("flickr_api", __dir__)

class RandFlickr < Sinatra::Base
  configure do
    set :root, File.expand_path("..", __dir__)
    enable :sessions
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader

    require "rack-livereload"
    use Rack::LiveReload
  end

  configure :production do
    require "raven"
    use Raven::Rack
    
    Raven.configure do |config|
      config.dsn = ENV["SENTRY_DSN"]
    end
  end

  get "/" do
    haml :index
  end

  get "/photo" do
    call env.merge("PATH_INFO" => "/photo/#{params[:user]}")
  end

  get "/photo/:user.json" do
    username = params[:user]
    photo = random_photo username 
    photo.merge!(browser_url: browser_url(username, photo))

    content_type :json
    MultiJson.dump photo
  end

  get "/photo/:user" do
    username = params[:user]
    session[:photo] = photo = random_photo username
    redirect to(browser_url(username, photo))
  end

  get "/photo/:user/:photoset_id/:photo_id" do
    @username = params[:user]
    @photo = session.delete(:photo) || FlickrApi.new(ENV["FLICKR_API_KEY"], @username).photo(params[:photoset_id], params[:photo_id])
    haml :photo
  end

  get "/style.css" do
    scss :style
  end

  private

  def random_photo(username)
    FlickrApi.new(ENV["FLICKR_API_KEY"], username).random_photo
  end

  def browser_url(username, photo)
    "/photo/#{username}/#{photo[:photoset][:id]}/#{photo[:id]}"
  end

  run! if app_file == $0
end
