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
  end

  configure :production do
    require "raven"
    use Raven::Rack
    
    Raven.configure do |config|
      config.dsn = ENV["SENTRY_DSN"]
    end
  end

  get "/" do
    call env.merge("PATH_INFO" => "/photo/jarm0")
  end

  get "/photo/:user" do
    username = params[:user]
    photo = FlickrApi.new(ENV["FLICKR_API_KEY"], username).random_photo
    session[:photo] = photo
    redirect to("/photo/#{username}/#{photo[:photoset][:id]}/#{photo[:id]}")
  end

  get "/photo/:user/:photoset_id/:photo_id" do
    @username = params[:user]
    @photo = session.delete(:photo) || FlickrApi.new(ENV["FLICKR_API_KEY"], @username).photo(params[:photoset_id], params[:photo_id])
    haml :index
  end

  get "/style.css" do
    scss :style
  end

  run! if app_file == $0
end
